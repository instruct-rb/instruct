module Instruct
  class << self
    attr_accessor :suppress_warnings
    attr_accessor :openai_loaded, :anthropic_loaded
    def default_model
      @default_model
    end
    def default_model=(model)
      @default_model = Instruct::Model.from_string_or_model(model)
    end
  end
end
