module Instruct
  module Expression
    class Expression
      # Base class for all expressions
      attr_reader :prompt_safe
      def prompt_safe?
       @prompt_safe == true
      end

      def +(other)
        other = PlainText.new(other) if other.is_a?(String)
        Concat.new(self, other)
      end
    end

    class PlainText < Expression
      attr_reader :text

      def initialize(text, prompt_safe:)
        @text = text
        @prompt_safe = prompt_safe
      end
    end

    class LLMFuture < Expression
      attr_reader :kwargs

      def initialize(prompt_safe: false, **kwargs)
        @kwargs = kwargs
      end
    end

    class ERBFuture < Expression
      attr_reader :template_block
      def initialize(template_block, prompt_safe: nil)
        @template_block = template_block
        @prompt_safe = prompt_safe
      end

      def prompt_safe?
        @prompt_safe || true
      end

      def should_mark_child_plain_text_as_prompt_safe?
        @prompt_safe || true
      end

      def should_mark_child_llm_future_as_prompt_safe?
        @prompt_safe || false
      end
    end

    class Concat < Expression
      attr_reader :expressions

      def initialize(*expressions)
        raise ArgumentError, 'At least one expression is required' if expressions.empty?
        raise ArgumentError, 'All expressions must be of type Expression' unless expressions.all? { |expression| expression.is_a?(Expression) }
        @expressions = expressions.flatten
      end
    end
  end
end
