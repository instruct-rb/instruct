require_relative "test_helper"

class RailsNotLoadedTest < Minitest::Test
  def test_rails_is_not_loaded
    assert !defined?(Rails::Railtie)
  end
end
