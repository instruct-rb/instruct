module Instruct::OpenAI
  class CompletionModel
    # we'll do things like ehis to generalize methods neded by middleware for automatic continue
    # json self healing, etc
    #def is_stop_finish_reason?()
    #end
    def middleware_chain
      @middleware_chain ||= Instruct::MiddlewareChain.new(middlewares: (@middlewares || []) << self)
    end

    def call(req, _next:)
      call_options = @options.merge(req.env[:openai_args]||{}).merge(req.env[:openai_deprecated_args]||{})
      if !@deprecated_arg_warned && req.env[:openai_deprecated_args] && !req.env[:openai_deprecated_args].empty? && @client.uri_base == 'https://api.openai.com/'
        puts "Warning: the follow args are deprecated by OpenAI and will be removed in the future: #{req.env[:openai_deprecated_args].keys.join(', ')}"
        @deprecated_arg_warned = true
      end
      if @middlewares.any? { |m| m.is_a?(Instruct::ChatCompletionMiddleware) || m == Instruct::ChatCompletionMiddleware }
        response = call_options[:stream] = Instruct::OpenAI::ChatCompletionResponse.new(**req.response_kwargs)
        call_options.merge!(req.prompt_object)
        _client_response = @client.chat(parameters: call_options)
      else
        if !@warned && @client.uri_base == 'https://api.openai.com/'
          puts "Warning: the completions endpoint is being shutdown by OpenAI in Jan 2025."
          @warned = true
        end
        response = call_options[:stream] = Instruct::OpenAI::CompletionResponse.new(**req.response_kwargs)
        call_options.merge!({prompt: req.prompt_object})
        _client_response = @client.completions(parameters: call_options)
      end
      response
    end


    def initialize(model: 'gpt-3.5-turbo-instruct', middlewares: nil, access_token: nil, log_errors: true, **options, &block)
      @middlewares = middlewares || []
      @middlewares << Middleware.new
      @options = options
      @options[:model] = model
      @client = OpenAI::Client.new( access_token: access_token || ENV['OPENAI_API_KEY'], log_errors: , options:) do |f|
        # f.adapter :async_http # would love to enable this but it's not working
        block.call(f) if block
      end
    end
  end
end
