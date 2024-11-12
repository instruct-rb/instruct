# A string that can have key-value attributes applied to ranges.
class Instruct::AttributedString
  attr_reader :string
  def initialize(string)
    @string = string
    @store = []
  end

  # Adds the given attributes in the hash to the range.
  # @param range [Range] The range to apply the attributes to.
  # @param attributes [Hash<Symbol, Object>] The attributes to apply to the range.
  def add_attributes(range, attributes)
    @store << { range: range, attributes: attributes }
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
        else
          result.merge!(stored_val[:attributes])
        end
      end
    end
    result
  end

  # Shallow duplicate. Attribute values are not deep copied.
  # @return [Instruct::AttributedString] duplicate of attributed string.
  def dup
    Instruct::AttributedString.new(@string).initialize_dup(@store)
  end

  private

  def initialize_dup(store)
    @store = store.dup
    self
  end

end
