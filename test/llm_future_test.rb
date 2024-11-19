require_relative 'test_helper'

class LMFutureTest < Minitest::Test
  using Instruct::Refinements
  def setup
    @mock = MockCompletionModel.new
    @lm = Instruct::LM.new(completion_model: @mock)
  end

  def process(expr)
    result = TranscriptString.new
    expr.process(lm: @lm) do |t|
      result << t
    end
    result
  end

  def test_gen_returns_a_future
    future = @lm.gen
    assert future.is_a?(Instruct::Expression::LLMFuture)
    @mock.verify
    @mock.expect_completion("", "a response")
    result = process future
    @mock.verify
    assert_equal "a response", result.to_s
  end
end
