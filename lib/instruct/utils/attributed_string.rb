# A string that can have key-value attributes applied to ranges.
class Instruct::AttributedString
  attr_reader :string
  def initialize(string = "")
    @string = string
    @store = []
  end

  # Adds the given attributes in the hash to the range.
  # @param range [Range] The range to apply the attributes to.
  # @param attributes [Hash<Symbol, Object>] The attributes to apply to the range.
  def add_attributes(range, attributes)
    @store << { range: range, attributes: attributes }
  end

  def add_arr_attributes(range, attributes)
    @store << { range: range, arr_attributes: attributes }
  end

  # Removes the given attributes from a range.
  # @param range [Range] The range to remove the attributes from.
  # @param attribute_keys [Array<Symbol>] The keys of the attributes to remove.
  def remove_attributes(range, *attribute_keys)
    @store << { range: range, delete: attribute_keys }
  end

  # Returns the attributes at a specific position.
  # @param position [Integer] The index in the string.
  # @return [Hash] The attributes at the given position.
  def attributes_at(position)
    result = {}
    @store.each do |stored_val|
      if stored_val[:range].include?(position)
        if stored_val[:delete]
          stored_val[:delete].each do |key|
            result.delete(key)
          end
        elsif stored_val[:arr_attributes]
          stored_val[:arr_attributes].each do |key, value|
            result[key] = [result[key]] if result.key?(key) && !result[key].is_a?(Array)
            if value.is_a?(Array)
              (result[key] ||= []).concat(value)
            else
              (result[key] ||= []).push(value)
            end
          end
        else
          result.merge!(stored_val[:attributes])
        end
      end
    end
    result
  end

  def length
    @string.length
  end

  # Appends a string and gets the new range
  def append_and_get_new_range(new_string)
    position = @string.length
    @string << new_string
    position..(@string.length - 1)
  end

  # Returns a filtered string the block will be called with each attribute,
  # value pair. It's an inclusive filter, so if the block returns true, any
  # character with that attribute will be included.
  #
  # This method has been slightly optimized to minimize allocations.
  # @return [Instruct::AttributedString::FilteredString] a filtered string.
  def filtered_string(&block)
    filtered_positions = []
    cached_block_calls = {}

    @string.each_char.with_index do |char, index|
      attributes = attributes_at(index)
      # Use the attributes object ID as the cache key to handle different attribute hashes
      cache_key = attributes.hash
      cached_result = cached_block_calls.fetch(cache_key) do
        result = block.call(attributes)
        cached_block_calls[cache_key] = result
        result
      end
      if cached_result
        filtered_positions << index
      end
    end

    # Group adjacent positions into ranges to minimize allocations
    ranges = []
    unless filtered_positions.empty?
      start_pos = filtered_positions.first
      prev_pos = start_pos
      filtered_positions.each_with_index do |pos, idx|
        next if idx == 0
        if pos == prev_pos + 1
          # Continue the current range
          prev_pos = pos
        else
          # End the current range and start a new one
          ranges << (start_pos..prev_pos)
          start_pos = pos
          prev_pos = pos
        end
      end
      # Add the final range
      ranges << (start_pos..prev_pos)
    end

    # Concatenate substrings from the original string based on the ranges
    result_string = ranges.map { |range| @string[range] }.join

    # Build the list of original positions
    original_positions = ranges.flat_map { |range| range.to_a }

    filtered_str = FilteredString.new(result_string)
    filtered_str.set_original_positions(original_positions)
    filtered_str
  end



  class FilteredString < String
    def set_original_positions(arr)
      raise ArgumentError, "Array must be same length as string" unless arr.length == length
      @original_positions = arr
    end

    def dup
      super.tap do |duped|
        duped.set_original_positions(@original_positions.dup)
      end
    end

    def original_position_at(index)
      @original_positions.fetch(index)
    end

    def original_ranges_for(filtered_range)
      raise ArgumentError, "Invalid range" unless filtered_range.is_a?(Range)
      raise ArgumentError, "Range out of bounds" if filtered_range.end >= length
      if filtered_range.begin > filtered_range.end
        raise ArgumentError, "Reverse range is not allowed"
      end
      if filtered_range.begin == filtered_range.end && filtered_range.exclude_end?
        return []
      end

      original_positions = @original_positions[filtered_range]
      ranges = []
      start_pos = original_positions.first
      prev_pos = start_pos

      original_positions.each_with_index do |pos, idx|
        next if idx == 0
        if pos == prev_pos + 1
          # Continue the current range
          prev_pos = pos
        else
          # End the current range and start a new one
          ranges << (start_pos..prev_pos)
          start_pos = pos
          prev_pos = pos
        end
      end
      # Add the final range
      ranges << (start_pos..prev_pos)
      ranges
    end
  end


  # Shallow duplicate. Attribute values are not deep copied.
  # @return [Instruct::AttributedString] duplicate of attributed string.
  def dup
    Instruct::AttributedString.new(@string.dup).send(:initialize_dup, @store)
  end

  def ==(other)
    false unless other.is_a?(Instruct::AttributedString)
    false unless string == other.string
    0.upto(length) do |i|
      if attributes_at(i) != other.attributes_at(i)
        return false
      end
    end
    true
  end

  private

  def initialize_dup(store)
    @store = store.dup
    self
  end

end
