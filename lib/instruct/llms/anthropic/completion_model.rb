module Instruct
  class Anthropic

    # params client_or_model_name [Anthropic::Client, String] Client instance or model name string
    # params model [String] Required model name to use for completion if client is provided as first arg
    attr_reader :default_request_env
    def initialize(client_or_model_name = "claude-3-5-sonnet-latest", middlewares: [], **kwargs)
      @middlewares = middlewares
      @default_request_env = kwargs
      @cached_clients = {}

      if client_or_model_name.is_a? ::Anthropic::Client
        @client = client_or_model_name
        @model_name = kwargs.delete(:model) if kwargs[:model]
        raise ArgumentError, "model: keyword argument must be a model name string when initializing with a client (see https://docs.anthropic.com/claude/docs/models-overview)" if @model_name.nil? || @model_name.empty?
      elsif client_or_model_name.is_a? String
        @model_name = client_or_model_name if client_or_model_name.is_a? String
        raise ArgumentError, "Model name must not be blank (see https://docs.anthropic.com/claude/docs/models-overview)" if @model_name.empty?
      else
        raise ArgumentError, "arg must be a model name string (see https://docs.anthropic.com/claude/docs/models-overview) or an instance of Anthropic::Client"
      end

      append_default_middleware_if_not_added
      set_access_token_from_env_if_needed
    end

    def middleware_chain(req)
      @middleware_chain ||= Instruct::MiddlewareChain.new(middlewares: (@middlewares || []) << self)
    end

    def call(req, _next:)
      client = build_client(req.env[:anthropic_client_opts])
      messages_params = req.env[:anthropic_messages_opts]||{}
      messages_params[:model] = @model_name if messages_params[:model].nil?
      warn_about_latest_model_if_needed(messages_params[:model])
      messages_params[:max_tokens] ||= max_tokens_if_not_set(messages_params[:model])
      messages_params.merge!(req.prompt_object)

      response = Instruct::Anthropic::MessagesCompletionResponse.new(**req.response_kwargs)
      messages_params[:stream] = Proc.new { |chunk| response.call(chunk) }

      begin
        Instruct.logger.info("Sending Anthropic Messages Completion Request: (#{request_params}) Client:(#{client.inspect})") if Instruct.logger.sev_threshold <= Logger::INFO
        _client_response = client.messages(parameters: messages_params)
      rescue Faraday::Error => e
        if e.respond_to?(:response_body)
          Instruct.err_logger.error("#{e.response_body}")
        else
          Instruct.err_logger.error("#{e.inspect}")
        end
        raise e
      end

      response
    end

    def max_tokens_if_not_set(model_name)
      if model_name.include?("claude-3-5-sonnet")
        8192
      else
        4096
      end
    end

    @@warned_about_latest_model = false
    def self.warned_about_latest_model?
      @@warned_about_latest_model
    end


    protected

    def append_default_middleware_if_not_added
      [Instruct::ChompMiddleware, Instruct::ChatCompletionMiddleware, Instruct::Anthropic::Middleware].each do |middleware|
        if !@middlewares.any? { |m| m.is_a?(middleware) }
          @middlewares << middleware.new
        end
      end
    end

    private

    def build_client(req_client_opts = {})
      if @client
        raise ArgumentError, "Client options must not be set when initializing with a client" if req_client_opts.any?
        return @client
      end

      @cached_clients[req_client_opts.hash] ||=  ::Anthropic::Client.new(req_client_opts)
    end


    def set_access_token_from_env_if_needed
      access_key = ENV["ANTHROPIC_ACCESS_TOKEN"] || ENV["ANTHROPIC_API_KEY"]
      @default_request_env[:access_token] = access_key if access_key && @default_request_env[:access_token].nil?
    end

    def warn_about_latest_model_if_needed(model_name)
      return if Instruct.suppress_warnings
      if model_name.end_with?("latest") && !@@warned_about_latest_model
        puts "Warning: You are using an anthropic model with the 'latest' suffix. This is alright for development, but not recommended for production. See https://docs.anthropic.com/en/docs/about-claude/models for more information."
      end
    end
  end
end
