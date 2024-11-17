module Instruct
  module Refinements
    refine String do
      # alias_method :old_double_arrow, :<<
      # private :old_double_arrow
      def <<(other)
        if other.is_a?(Transcript) || other.is_a?(Transcript::Completion)
        raise Instruct::Error, <<~ERR.chomp
          Consider using become gem here to make string become a transcript, if you see this error you should
          convert your string to an Instruct::Transcript either using Instruct::Transcript.new or "safe string".prompt_safe
          ERR
        else
          super
        end
      end
        # alias_method :instruct_old_plus, :+
        # private :instruct_old_plus

        def +(other)
          if other.is_a?(Transcript) || other.is_a?(Transcript::Completion)
            Transcript.new(self) + other
          else
            super
          end
        end

        def prompt_safe
          string = self.is_a?(AttributedString) ? self : Transcript.new(self)
          string.add_attrs(safe: true)
        end
    end
    #   alias_method :instruct_old_plus, :+
    #   private :instruct_old_plus

    #   def +(other)
    #     if other.is_a?(Instruct::Expression::Expression)
    #       wrapped = Instruct::Expression::PlainText.new(self)
    #       Instruct::Expression::Concat.new(wrapped, other)
    #     else
    #       instruct_old_plus(other)
    #     end
    #   end

    # end
    # refine Object do
    #   def erb(safe: nil, &block)
    #     Instruct::Expression::ERBFuture.new(template: block.call, binding: block.binding, safe:)
    #   end
    #   def gen(**kwargs)
    #     Instruct::Expression::LLMFuture.new(**kwargs)
    #   end
    # end
  end
end
