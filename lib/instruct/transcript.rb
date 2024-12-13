module Instruct
  class Transcript < AttributedString
    include Instruct::Serializable
    set_instruct_class_id 1


    def call(**kwargs, &streaming_block)
      raise ArgumentError, "cannot add transcript to call on transcript" if kwargs[:transcript]

      prompt = Transcript.new

      gens, substrings = split_substrings_and_gen_attachments
      results = []

      gens.each_with_index do |gen, i|
        prompt += substrings[i]
        gen.transcript = prompt
        completion = gen.call(**kwargs, &streaming_block)
        prompt += completion
        results << completion
      end

      results.length > 1 ? results : results.first
    end


    def +(other, *args, apply_completions: true)
      self.dup.concat(other, *args, apply_completions:)
    end

    # Unlike normal strings << is not the same as concat. << first performs the concat, then runs call on the
    # new transcript, before adding the result to the transcript.
    def <<(other, *args, **kwargs)
      concat(other, *args, perform_call: true, apply_completions: true, **kwargs)
    end

    def safe_concat(string)
      string = Transcript.new(string, safe: true) if string.is_a?(String)
      concat(string)
    end

    def concat(other, *args, perform_call: false, apply_completions: false)
      if other.is_a?(Array) && other.all? { |obj| obj.is_a?(Transcript::Completion) } && !other.empty?
        return concat(*(other + args), perform_call:, apply_completions: )
      end
      if other.is_a?(Transcript::Completion) && apply_completions
        other.apply_to_transcript(self)
      else
        super(other)
      end
      if args.size.positive?
        return self.concat(*args, perform_call: perform_call, apply_completions: apply_completions)
      end
      if perform_call && result = self.call
        self.concat(result, perform_call: false, apply_completions: true)
      else
        self
      end
    end

    def split_substrings_and_gen_attachments
      gens = []
      substrings = []
      deferred_gens = self.attachments_with_positions.filter { |obj| obj[:attachment].is_a?(Instruct::Gen) }
      next_substring_index = 0
      deferred_gens.each do |obj|
        position = obj[:position]
        substrings << self[next_substring_index..position]
        gens << obj[:attachment]
        next_substring_index = position + 1
      end
      substrings << self[next_substring_index..self.length - 1] if next_substring_index <= self.length - 1
      return [gens, substrings]
    end

    def hide_range_from_prompt(range, by:)
      add_attrs(range, "hidden_#{by}": true)
    end

    def unhide_range_from_prompt(range, by:)
      remove_attrs(range, "hidden_#{by}".to_sym)
    end

    def prompt_object
      prompt_object = self.dup
      hidden_chars = prompt_object.filter do |attrs|
        len_hidden_attrs(attrs).positive?
      end
      return prompt_object if hidden_chars.empty?
      ranges = hidden_chars.original_ranges_for(0..hidden_chars.length - 1)
      ranges.each do |range|
        prompt_object[range] = ''
      end
      prompt_object
    end


    def to_s(gen: :emoji)
      string = super()
      deferred_gens = self.attachments_with_positions.filter { |obj| obj[:attachment].is_a?(Instruct::Gen) }
      deferred_gens.each do |obj|
        position = obj[:position]
        case gen
        when :no_change
        when :hide
          string[position] = ''
        when :expand
          string[position] = obj[:attachment].to_s
        when :emoji
          string[position] =  "💬"
        end
      end
      string
    end

    def captured(key)
      return nil unless @captured
      @captured[key]
    end

    def capture(key, **kwargs)
      # TODO: attributed string should support -1
      last_attachment = self.attachment_at(self.length - 1)
      if last_attachment.is_a?(Instruct::Gen)
        last_attachment.capture(key, **kwargs)
      else
       raise ArgumentError, "Cannot capture on a transcript that does not end with a Gen"
      end
      self
    end

    private

    def add_captured(value, key, list_key)
      @captured ||= {}
      if key
        @captured[key] = value
      end
      if list_key
        @captured[list_key] ||= [@captured[list_key]].compact
        @captured[list_key] << value
      end
    end

    def len_hidden_attrs(attrs)
      attrs.keys.filter { |key| key.to_s.start_with?('hidden_') }.length
    end


    # When a generated result is added to or concatted to a transcript, the
    # transcript replaces its contents with modified transcript if
    # the original transcript is the same as the transcript. This enables
    # middleware to make modifications to the transcript that persist
    # only when the result is added to the transcript. In all other cases,
    # the transcript is not modified and the result is the normal result.
    class Completion < AttributedString
      include Instruct::Serializable
      set_instruct_class_id 3
      attr_reader :prompt
      def initialize(*args, duped_transcript: nil, **kwargs)
        super(*args, **kwargs)
        @prompt = duped_transcript
      end

      def apply_to_transcript(transcript)
        deferred_gens = transcript.attachments_with_positions.filter { |obj| obj[:attachment].is_a?(Instruct::Gen) }
        first_gen = deferred_gens.first
        if first_gen.nil?
          return transcript.replace(transcript.+(self, apply_completions: false))
        end
        # if the transcript matches the prompt, we replace the transcript with the updated transcript
        # otherwise we just append the updated transcript to the transcript
        # in both cases we remove the gen attachment
        if (first_gen && transcript[..first_gen[:position]] == prompt) || (first_gen.nil? && transcript == prompt)
          transcript.send(:add_captured, self, @key, @list_key)
          transcript[..first_gen[:position]] = @updated_transcript.+(self, apply_completions: false)
        else
          transcript[first_gen[:position]] = self
        end
        transcript
      end

      def +(other)
        return super unless other.is_a?(Transcript)
        Transcript.new + self + other
      end

      # Returns the latest chunk in the completion unless a chunk argument is provided
      def get_chunk(chunk = self.attrs_at(self.length - 1).fetch(:stream_chunk, nil))
        filtered = self.filter { |attrs| attrs[:stream_chunk] == chunk }
        ranges = filtered.original_ranges_for(0..(filtered.length - 1))
        ranges.map { |range| self[range] }.join
      end


      private

      def first_gen(transcript)
        return nil if deferred_gens.empty?
        deferred_gens
      end

      def updated_transcript=(duped_transcript)
        @updated_transcript = duped_transcript
      end

      def captured=(key, list_key)
        @key, @list_key = key, list_key
      end

    end

    private


  end
end
