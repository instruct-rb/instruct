module Instruct
  class OpenAI
    attr_reader :default_request_env

    def middleware_chain(req)
      middlewares = @middlewares || []
      append_default_middleware_if_not_added(req, middlewares)
      @middleware_chain ||= Instruct::MiddlewareChain.new(middlewares: (middlewares << self))
    end

    def initialize(client_or_model_name = 'gpt-3.5-turbo-instruct', middlewares: [], **kwargs)
      @middlewares = middlewares
      @default_request_env = kwargs
      @cached_clients = {}

      if client_or_model_name.is_a? ::OpenAI::Client
        @client = client_or_model_name
        @model_name = kwargs.delete(:model) if kwargs[:model]
        raise ArgumentError, "model: keyword argument must be a model name string when initializing with a client" if @model_name.nil? || @model_name.empty?
      elsif client_or_model_name.is_a? String
        @model_name = client_or_model_name
        raise ArgumentError, "Model name must not be blank" if @model_name.empty?
      else
        raise ArgumentError, "arg must be a model name string or an instance of OpenAI::Client"
      end

      set_access_token_from_env_if_needed
    end

    def call(req, _next:)
      client = build_client(req.env[:openai_client_opts] || {})

      request_params = req.env[:openai_args] || {}
      request_params[:model] = @model_name if request_params[:model].nil?

      if is_chat_model?(req)
        response = request_params[:stream] = Instruct::OpenAI::ChatCompletionResponse.new(**req.response_kwargs)
        request_params.merge!(req.prompt_object)
        warn_about_deprecated_args(req.env[:openai_deprecated_args]) if req.env[:openai_deprecated_args]
        begin
          Instruct.logger.info("Sending OpenAI Chat Completion Request: (#{request_params}) Client:(#{client.inspect})") if Instruct.logger.sev_threshold <= Logger::INFO
          _client_response = client.chat(parameters: request_params)
        rescue Faraday::Error => e
          if e.respond_to?(:response_body)
            Instruct.err_logger.error("#{e.response_body}")
          else
            Instruct.err_logger.error("#{e.inspect}")
          end
          raise e
        end
      else
        warn_about_completions_endpoint if !@warned
        response = request_params[:stream] = Instruct::OpenAI::CompletionResponse.new(**req.response_kwargs)
        request_params.merge!({prompt: req.prompt_object})
        begin
            Instruct.logger.info("Sending OpenAI Completion Request: (#{request_params}) Client:(#{client.inspect})") if Instruct.logger.sev_threshold <= Logger::INFO
          _client_response = client.completions(parameters: request_params)
        rescue Faraday::Error => e
          if e.respond_to?(:response_body)
            Instruct.err_logger.error("#{e.response_body}")
          else
            Instruct.err_logger.error("#{e.inspect}")
          end
          raise e
        end
      end
      response
    end

    protected

    def append_default_middleware_if_not_added(req, middlewares)
      openai_middlewares = [Instruct::OpenAI::Middleware.new]
      if is_chat_model?(req)
        openai_middlewares = [Instruct::ChompMiddleware.new, Instruct::ChatCompletionMiddleware.new] + openai_middlewares
      end
      openai_middlewares.each do |middleware|
        if !middlewares.any? { |m| m.is_a?(middleware.class) }
          middlewares << middleware
        end
      end
    end

    private

    def is_chat_model?(req)
      !(req.env[:use_completion_endpoint] || ((req.env[:model] || @model_name) == 'gpt-3.5-turbo-instruct'))
    end

    def build_client(req_client_opts = {})
      if @client
        raise ArgumentError, "Client options must not be set when initializing with a client" if req_client_opts.any?
        return @client
      end

      client_opts = @default_request_env.select { |k, _| Instruct::OpenAI::Middleware::CLIENT_PARAMS.include?(k) }
      client_opts.merge!(req_client_opts)

      @cached_clients[client_opts.hash] ||= ::OpenAI::Client.new(
        access_token: client_opts[:access_token] || ENV['OPENAI_API_KEY'] || ENV['OPENAI_ACCESS_TOKEN'],
        uri_base: client_opts[:uri_base],
        request_timeout: client_opts[:request_timeout],
        extra_headers: client_opts[:extra_headers]
      )
    end

    def set_access_token_from_env_if_needed
      access_key = ENV['OPENAI_API_KEY'] || ENV['OPENAI_ACCESS_TOKEN']
      @default_request_env[:access_token] = access_key if access_key && @default_request_env[:access_token].nil?
    end

    def warn_about_deprecated_args(deprecated_args)
      return if Instruct.suppress_warnings || @deprecated_arg_warned
      if deprecated_args && !deprecated_args.empty?
        puts "Warning: the follow args are deprecated by OpenAI and will be removed in the future: #{deprecated_args.keys.join(', ')}"
        @deprecated_arg_warned = true
      end
    end

    def warn_about_completions_endpoint
      return if Instruct.suppress_warnings || @warned
      puts "Warning: the completions endpoint is being shutdown by OpenAI in Jan 2025."
      @warned = true
    end
  end
end
