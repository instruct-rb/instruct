module Instruct
  module Expression
    class Expression
      # Base class for all expressions
      def +(other)
        other = PlainText.new(other) if other.is_a?(String)
        Concat.new(self, other)
      end
    end

    class PlainText < Expression
      attr_reader :text

      def initialize(text)
        @text = text
      end
    end

    class LLMFuture < Expression
      attr_reader :kwargs

      def initialize(kwargs)
        @kwargs = kwargs
      end
    end

    class ERBFuture < Expression
      attr_reader :template_block
      def initialize(template_block)
        @template_block = template_block
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
