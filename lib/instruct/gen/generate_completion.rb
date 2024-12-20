module Instruct
  class GenerateCompletion
    def initialize(prompt:, model:, streaming_block:nil, capture_key:, capture_list_key:, gen_and_call_kwargs:)
      @prompt = prompt
      @model = model
      @streaming_block = streaming_block
      @capture_key = capture_key
      @capture_list_key = capture_list_key
      @gen_and_call_kwargs = gen_and_call_kwargs
      @run = false
    end

    def call(calling_gen:)
      raise RuntimeError, "Cannot call a completed Gen" if @run
      @run = true

      @original_prompt = @prompt.dup
      completion = Prompt::Completion.new
      prompt = prompt_with_gen_attachment_removed(calling_gen)
      @request = Gen::CompletionRequest.new(prompt: prompt, completion: completion, env: build_request_env)
      if @streaming_block
        @request.add_stream_handler do |response|
          response = prepare_completion_for_return(response)
          @streaming_block.call(response)
        end
      end
      middleware = build_model_middleware_chain(@request)
      response = middleware.execute(@request)
      completion = response.attributed_string
      prepare_completion_for_return(completion)
    end

    private

    def prepare_completion_for_return(completion)
      completion._prepare_for_return(prompt: @original_prompt, captured_key: @capture_key, captured_list_key: @capture_list_key, updated_prompt: @request.prompt)
      completion
    end

    def build_request_env
      @model.default_request_env.merge(@gen_and_call_kwargs)
    end

    def build_model_middleware_chain(request)
      if @model.respond_to?(:middleware_chain)
        @model.middleware_chain(request)
      else
        @model
      end
    end

    def prompt_with_gen_attachment_removed(calling_gen)
      if calling_gen && @prompt.attachment_at(@prompt.length - 1) == calling_gen
        @prompt[...-1]
      else
        @prompt.dup
      end
    end

  end
end
