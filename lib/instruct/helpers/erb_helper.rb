module Instruct
  module Helpers
    P_HELPER_ERROR_MESSAGE = "the p(rompt) helpers should be called using a block p{<arg>} not p(<arg>)"
    module ERBHelper
      def p(*args, &block)
        if block_given?
          Instruct::CompileERB.new(template: yield, _binding: block.binding).prompt
        elsif args.length == 0
          P.new
        else
          Kernel.p(*args)
        end
      end
    end
    class P
      def system(*args, &block)
        raise ArgumentError, P_HELPER_ERROR_MESSAGE if args.length > 0
        Prompt.new("\nsystem: ", safe: true)+ Instruct::CompileERB.new(template: yield, _binding: block.binding).prompt
      end
      def user(*args, &block)
        raise ArgumentError, P_HELPER_ERROR_MESSAGE if args.length > 0
        Prompt.new("\nuser: ", safe: true) + Instruct::CompileERB.new(template: yield, _binding: block.binding).prompt
      end
      def assistant(*args, &block)
        raise ArgumentError, P_HELPER_ERROR_MESSAGE if args.length > 0
        Prompt.new("\nassistant: ", safe: true) + Instruct::CompileERB.new(template: yield, _binding: block.binding).prompt
      end
    end
  end
end
