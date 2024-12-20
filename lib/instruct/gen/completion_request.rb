class Instruct::Gen
  class CompletionRequest
    def initialize(prompt:, completion:, env:)
      @env = env
      @prompt = prompt
      @completion = completion
      @prompt_transformers = []
      @stream_handlers = []
    end

    def id
      @id ||= SecureRandom.hex(10)
    end

    # returns the respose a TranscriptString from the model

    def env
      @env
    end

    def prompt
      @prompt
    end

    def response_kwargs
      { completion: @completion, stream_handlers: stream_handlers }
    end

    def prompt_object
      prompt_object = @prompt.prompt_object
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
    # array containing [status, completion_string]
    def add_stream_handler(&block)
      @stream_handlers << block
    end

    def stream_handlers
      @stream_handlers.reverse
    end




  end
end
