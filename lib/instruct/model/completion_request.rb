module Instruct::Model
  class CompletionRequest
    attr_reader :env
    def initialize(transcript, **kwargs)
      @env = kwargs.merge({ transcript: transcript, unmodified_transcript: transcript.dup })
    end

    def transcript
      @env[:transcript]
    end

  end
end
