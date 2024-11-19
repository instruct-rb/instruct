require_relative 'test_helper'

class ChompMiddlewareTest < Minitest::Test
  using Instruct::Refinements
  def setup
    @mock = MockCompletionModel.new(middlewares: [Instruct::Model::ChompMiddleware])
    @lm = Instruct::LM.new(completion_model: @mock)
  end

  def test_that_a_prompt_is_chomped
    @mock.expect_completion("a prompt:", " a response")
    @lm += 'a prompt: ' + gen
    @mock.verify
    assert_equal "a prompt: a response", @lm.transcript_string
  end
end
