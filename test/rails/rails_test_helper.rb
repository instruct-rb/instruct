require "bundler/setup"
require "rails"
require "instruct"
require_relative "../test_helper"

# This is used to initialize the railties
class TestApp < Rails::Application
  config.eager_load = false

  logger = ActiveSupport::Logger.new(STDOUT)
  logger.formatter = config.log_formatter
  config.logger = ActiveSupport::TaggedLogging.new(logger)



  # Hide warning
  config.active_support.to_time_preserves_timezone = :zone
end

Rails.application.initialize!
