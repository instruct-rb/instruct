class Instruct::Gen
  class CompletionRequest
    def initialize(transcript, completion, **kwargs)
      @env = kwargs.reject { |k, v| [:arr_name , :name].include?(k) }
      @transcript = transcript.dup
      @completion = completion
      @prompt_transformers = []
      @stream_handlers = []
    end

    def id
      @id ||= SecureRandom.hex(10)
    end

    # returns the respose a TranscriptString from the model
    def execute(model)
      # TODO: this logic can probably move onto the model
      if model.respond_to?(:middleware_chain)
        model = model.middleware_chain(self)
      end
      model.execute(self)
    end

    def env
      @env
    end

    def transcript
      @transcript
    end

    def response_kwargs
      { completion: @completion, stream_handlers: stream_handlers }
    end

    def prompt_object
      prompt_object = @transcript.prompt_object
      @prompt_transformers.each do |transformer|
        prompt_object = transformer.call(prompt_object)
      end
      prompt_object
    end

    # Add a block that will map the prompt to a transformed prompt Runs in the
    # order they are added. It will be passed the prompt object and should
    # return a new or modified prompt object
    def add_prompt_transform(&block)
      @prompt_transformers << block
    end

    # Add a block to handle the streamed responses, it will be passed
    # the response TranscriptString and it can modify it. Keep
    # in mind that this will be called each time a new chunk is added.
    # The same logic will often be used in the middleware to check
    # the final response.
    # These are called in reverse order of addition.
    # array containing [status, transcript_string]
    def add_stream_handler(&block)
      @stream_handlers << block
    end

    def stream_handlers
      @stream_handlers.reverse
    end




  end
end
