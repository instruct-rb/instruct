require "bundler/setup"
Bundler.require(:default)

require "minitest/autorun"
require "minitest/pride"

require_relative "utils/completion_mock"

class Minitest::Test
  # custom assertions
end
