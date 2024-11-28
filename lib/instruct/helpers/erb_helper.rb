module Instruct::Helpers
 module ERBHelper
  def erb(&block)
    raise ArgumentError, "block required" unless block_given?
    template = yield if block_given?
    # Transcript.new(template, safe: true)
    Instruct::CompileERB.new(template: , _binding: block.binding).transcript
  end
 end
end
