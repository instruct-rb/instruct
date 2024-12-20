require "bundler/setup"
Bundler.require(:default)

require "minitest/autorun"
require "minitest/pride"

require_relative "utils/mock_completion_stream_response"
require_relative "utils/mock_completion_model"
require_relative "utils/assertions"
require_relative "utils/middleware"

class Minitest::Test
  Instruct.suppress_warnings = true
  include Assertions
end
