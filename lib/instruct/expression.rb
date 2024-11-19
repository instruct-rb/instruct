module Instruct
  # TODO: lets turn these into string subclasses so that the + - works better
  # this might let us do some nicer stuff with erb as well
  # It also lets us do lm.f{} + "\n"
  module Expression
    class Expression
      # Base class for all expressions
      attr_reader :safe
      def safe?
       @safe == true
      end

      # This is called by the lm processing the expression, it should
      # call the block with (string [TranscriptString], finalized [bool])
      #
      # When not finalized, the string will not be appended to the transcript
      # but it will still be usable in debugging and stream visualizations.
      #
      # This lets middleware decide after a generation if they would like to retry
      # or finalize the string.
      def process(lm:, &block)
        raise NotImplementedError, "this should return a transcript string which can be appended to the an lm's current transcript"
      end

      def +(other)
        other = PlainText.new(other) if other.is_a?(String)
        Concat.new(self, other)
      end
    end

    class PlainText < Expression

      def initialize(text, safe: false)
        @ts = text.is_a?(TranscriptString) ? text : TranscriptString.new(text)
        range = 0..@ts.length - 1
        @ts.add_attrs(range, safe: safe, _force: true) unless safe.nil?
      end

      def process(lm:, &block) = yield(@ts, true)
      def inspect = @ts.inspect
      def to_s = @ts.to_s
    end


    # This is just a tiny wrapper around completion request
    class LLMFuture < Expression
      attr_reader :kwargs

      def initialize(safe: false, **kwargs)
        @kwargs = kwargs
      end

      def process(lm:, &result)
        resp = lm.gen(deferred: false, **kwargs)
        result.call(resp)
      end
    end

    class Concat < Expression

      attr_reader :expressions
      def initialize(*expressions)
        raise ArgumentError, 'At least one expression is required' if expressions.empty?
        raise ArgumentError, 'All expressions must be of type Expression' unless expressions.all? { |expression| expression.is_a?(Expression) }
        @expressions = expressions.flatten
      end

      def to_s =  @expressions.map(&:to_s).join(' + ')
      def inspect = "<Concat: #{to_s}>"
    end
  end
end
