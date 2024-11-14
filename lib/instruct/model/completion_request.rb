module Instruct::Model
  class CompletionRequest
    def initialize(transcript, **kwargs)
      @env = kwargs.reject { |k, v| [:arr_name , :name].include?(k) }
      @transcript = transcript
      @unmodified_transcript = transcript.dup
    end

    def env
      @env
    end

    def transcript
      @transcript
    end

    def prompt_object
      transcript.to_s
    end

    # This might be a nice API for adding middleware which can modify the transcript
    # for different models, or to add extra information
    #def add_transcript_transform(&block)
    #end

    # This might be a nice API to have for streaming responses back to HTML
    # essentially allows middleware to add a handler that will be called
    # with a buffer of the currently streamed response
    #def add_stream_handler(&block)
    #end


  end
end
