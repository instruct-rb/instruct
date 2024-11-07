module Instruct::Model
  class CompletionRequest
    attr_reader :env
    def initialize(transcript)
      # prompt is the transcript, this contains more info than just the text, it also includes the type of expression
      @env = { prompt: prompt }
    end

    def prompt
      env[:prompt]
    end
  end
end
