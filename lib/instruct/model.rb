module Instruct
  module Model
    def self.from_string(string, **kwargs)
        self.openai(string, **kwargs)
    end
    def self.openai(string, **kwargs)
      case string
      when "gpt-3.5-turbo-instruct"
        self.openai_load_completion_model(string, **kwargs)
      else
        self.openai_load_conversation_model(string, **kwargs)
      end
    end

    private
    def self.openai_load_conversation_model(model, **kwargs)
      raise RuntimeError, "Cannot load an OpenAI API model without ruby-openai gem." unless Instruct.openai_loaded
      middlewares = kwargs.delete(:middlewares) || []
      middlewares << ChompMiddleware.new
      middlewares << ChatCompletionMiddleware.new
      Instruct::OpenAI::CompletionModel.new(model:, middlewares:, **kwargs)
    end
    def self.openai_load_completion_model(model, **kwargs)
      raise RuntimeError, "Cannot load an OpenAI API model without ruby-openai gem." unless Instruct.openai_loaded
      Instruct::OpenAI::CompletionModel.new(model:, **kwargs)
    end
  end
end
