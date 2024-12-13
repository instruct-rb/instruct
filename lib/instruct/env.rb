require 'logger'

module Instruct
  class << self
    attr_accessor :suppress_warnings
    attr_accessor :openai_loaded, :anthropic_loaded
    attr_writer :logger, :err_logger
    def logger
      @logger ||= Logger.new(STDOUT).tap do |l|
        l.sev_threshold = ENV.fetch('INSTRUCT_LOG_LEVEL', 'warn').to_sym
      end
    end
    def err_logger
      @error_logger ||= Logger.new(STDERR).tap do |l|
        l.sev_threshold = ENV.fetch('INSTRUCT_LOG_LEVEL', 'warn').to_sym
      end
    end

    def default_model
      @default_model
    end
    def default_model=(model)
      @default_model = Instruct::Model.from_string_or_model(model)
    end

  end
end
