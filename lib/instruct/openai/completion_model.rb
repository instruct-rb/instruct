module Instruct
  class OpenAICompletionModel
    # we'll do things like ehis to generalize methods neded by middleware for automatic continue
    # json self healing, etc
    #def is_stop_finish_reason?()
    #end
    def middleware_chain
      @middleware_chain ||= Instruct::MiddlewareChain.new(middlewares: @middlewares || [])
    end

    def call(req, _next:)
      @options.merge!(req.env)
      @client.completion(parameters: @options.merge(prompt: req.prompt_object))
    end


    def initialize(model: 'gpt-3.5-turbo-instruct', middlewares: nil, access_token: nil, log_errors: true, **options)
      @middlewares = middlewares
      @options = options
      @options[:model] = model
      @client = OpenAI::Client.new(
        access_token: access_token || ENV['OPENAI_API_KEY'],
        log_errors:
      )
    end
  end
end
