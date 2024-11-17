module Instruct::Helpers
  module ERBHelper
    def p(&block)
      raise ArgumentError, "block required" unless block_given?
      Instruct::CompileERB.new(template: yield, _binding: block.binding).transcript
    end
  end
end
