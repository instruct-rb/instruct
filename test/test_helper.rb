require "bundler/setup"
Bundler.require(:default)

require "minitest/autorun"
require "minitest/pride"

require_relative "utils/completion_mock"
require_relative "utils/mock_completion_stream_response"
require_relative "utils/mock_completion_model"

class Minitest::Test
  # custom as
end
