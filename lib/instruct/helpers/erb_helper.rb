module Instruct
  module Helpers
    P_HELPER_ERROR_MESSAGE = "the p(rompt) helpers should be called using a block p{<arg>} not p(<arg>)"
    module ERBHelper
      def p(*args, &block)
        raise ArgumentError, P_HELPER_ERROR_MESSAGE if args.length > 0
        if block_given?
          Instruct::CompileERB.new(template: yield, _binding: block.binding).transcript
        else
          P.new
        end
      end
    end
    class P
      def system(*args, &block)
        raise ArgumentError, P_HELPER_ERROR_MESSAGE if args.length > 0
        return Transcript.new("\nsystem: ", safe: true)+ Instruct::CompileERB.new(template: yield, _binding: block.binding).transcript
      end
      def user(*args, &block)
        raise ArgumentError, P_HELPER_ERROR_MESSAGE if args.length > 0
        return Transcript.new("\nuser: ", safe: true) + Instruct::CompileERB.new(template: yield, _binding: block.binding).transcript
      end
      def assistant(*args, &block)
        raise ArgumentError, P_HELPER_ERROR_MESSAGE if args.length > 0
        return Transcript.new("\nassistant: ", safe: true) + Instruct::CompileERB.new(template: yield, _binding: block.binding).transcript
      end
    end
  end
end
