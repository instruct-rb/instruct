module Instruct
  class << self
    attr_accessor :default_model
    def default_model
      @default_model ||= 'gpt-3.5-turbo-instruct'
    end
    attr_accessor :openai_loaded
  end
end
