require_relative '../test_helper'

class ChompMiddlewareTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new(middlewares: [Instruct::ChompMiddleware])
    self._instruct_default_model = @mock
  end

  def test_that_a_prompt_is_chomped
    @mock.expect_completion("a prompt:", " a response")
    prompt = Instruct::Transcript.new("a prompt: ") + gen()
    result = prompt.call
    assert_equal("a response", result.to_s)
    @mock.verify
    assert_equal "a prompt: a response", (prompt + result)
    assert_equal "a prompt: a response", (prompt + result).prompt_object.to_s
  end

  def test_that_it_stops_stream_handlers_when_chunked_whitespace
    @mock.expect_completion("a prompt:", [" ", " ", " a", " response"])
    prompt = Instruct::Transcript.new("a prompt:   ") + gen()
    expect = ["a", "a response"]
    result = prompt.call do |resp|
      assert_equal expect.shift, resp.to_s
    end
    assert_equal("a response", result.to_s)
    @mock.verify
  end
end
