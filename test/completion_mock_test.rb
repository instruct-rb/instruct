require_relative "test_helper"

class CompletionMockTest < Minitest::Test
  def test_add_expected_completion
    mock = CompletionMock.new
    mock.add_expected_completion("a prompt", "a response")
    assert_equal mock.completion("a prompt"), "a response"
    mock.verify

    # Test with keyword arguments
    mock = CompletionMock.new
    mock.add_expected_completion("a second prompt", "a response with stop", stop: "\n")
    assert_equal mock.completion("a second prompt", stop: "\n"), "a response with stop"
    mock.verify
  end
end
