module Instruct
  module Refinements
    refine String do
      def prompt_safe
        Instruct::Expression::PlainText.new(self, safe: true)
      end
      alias_method :instruct_old_plus, :+
      private :instruct_old_plus

      def +(other)
        if other.is_a?(Instruct::Expression::Expression)
          wrapped = Instruct::Expression::PlainText.new(self)
          Instruct::Expression::Concat.new(wrapped, other)
        else
          instruct_old_plus(other)
        end
      end

    end
    refine Object do
      def erb(safe: nil, &block)
        Instruct::Expression::ERBFuture.new(template: block.call, binding: block.binding, safe:)
      end
      def gen(**kwargs)
        Instruct::Expression::LLMFuture.new(**kwargs)
      end
    end
  end
end
