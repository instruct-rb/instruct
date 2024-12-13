module Instruct
  module Model
    def self.from_string_or_model(model)
      if model.class == String
        self.from_string(model)
      elsif model.respond_to?(:call)
        model
      else
        raise ArgumentError, "Model must be a model name string or respond to call."
      end
    end

    def self.from_string(string, **kwargs)
      if string.include?("claude") || string.include?("anthropic")
        Instruct::Anthropic.new(string, **kwargs)
      else
        Instruct::OpenAI.new(string, **kwargs)
      end
    end
  end
end
