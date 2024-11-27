module Instruct
  class Transcript < AttributedString

    def call(**kwargs)
      raise ArgumentError, "cannot add transcript to call on transcript" if kwargs[:transcript]

      prompt = Transcript.new

      gens, substrings = split_substrings_and_gen_attachments
      results = []

      gens.each_with_index do |gen, i|
        prompt += substrings[i]
        gen.transcript = prompt
        completion = gen.call(**kwargs)
        prompt += completion
        results << completion
      end

      results.length > 1 ? results : results.first
    end


    def +(other, *args, apply_completions: true)
      if other.is_a?(Array) && other.all? { |obj| obj.is_a?(Transcript::Completion) } && !other.empty?
        return self.+(*(other + args), apply_completions: apply_completions)
      end
      result = if other.is_a?(Transcript::Completion) && apply_completions
        other.apply_to_transcript(self.dup)
      else
        super(other)
      end
      args.empty? ? result : result.+(*args, apply_completions:)
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
      return [gens, substrings]
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

    # When a generated result is added to or concatted to a transcript, the
    # transcript replaces its contents with modified transcript if
    # the original transcript is the same as the transcript. This enables
    # middleware to make modifications to the transcript that persist
    # only when the result is added to the transcript. In all other cases,
    # the transcript is not modified and the result is the normal result.
    class Completion < AttributedString
      attr_reader :prompt
      def initialize(duped_transcript)
        super()
        @prompt = duped_transcript
      end

      def apply_to_transcript(transcript)
        deferred_gens = transcript.attachments_with_positions.filter { |obj| obj[:attachment].is_a?(Instruct::Gen) }
        first_gen = deferred_gens.first
        return transcript.+(self, apply_completions: false) if first_gen.nil?
        # if the transcript matches the prompt, we replace the transcript with the updated transcript
        # otherwise we just append the updated transcript to the transcript
        # in both cases we remove the gen attachment
        if transcript == prompt
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


      private

      def first_gen(transcript)
        return nil if deferred_gens.empty?
        deferred_gens
      end

      def updated_transcript=(duped_transcript)
        @updated_transcript = duped_transcript
      end

    end

    private


  end
end
