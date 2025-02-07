require "logger"

module Instruct
  class << self
    include Instruct::Helpers::ERBHelper
    include Instruct::Helpers::GenHelper

    attr_accessor :suppress_warnings
    attr_accessor :openai_loaded, :anthropic_loaded
    attr_writer :logger, :err_logger
    def logger
      @logger ||= Logger.new(STDOUT).tap do |l|
        l.sev_threshold = ENV.fetch("INSTRUCT_LOG_LEVEL", "warn").to_sym
      end
    end
    def err_logger
      @error_logger ||= Logger.new(STDERR).tap do |l|
        l.sev_threshold = ENV.fetch("INSTRUCT_LOG_LEVEL", "warn").to_sym
      end
    end

    def default_model
      if @default_model.is_a?(Array) && @default_model.length == 2
        return Instruct::Model.from_string(@default_model.first, **@default_model.last)
      end
      @default_model
    end

    def default_model=(model)
      @default_model = model
    end

    def set_default_model(model, **kwargs)
      if model.is_a?(String)
        @default_model = [ model, kwargs ]
      elsif kwargs.any?
        raise ArgumentError, "Cannot pass kwargs when passing a model object"
      else
        @default_model = model
      end
      true if @default_model
    end
  end
end
