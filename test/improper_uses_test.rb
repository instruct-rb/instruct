require 'test_helper'
class ImproperUsesTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new
    self.instruct_default_model = @mock
  end

  def test_add_results
    @mock.expect_completion("The capital of France is ", "Paris.")
    result = gen("The capital of France is ")
    sum = result + result
    assert_equal Instruct::Prompt::Completion, sum.class
    assert_equal "Paris.Paris.", sum.to_s
  end

  def test_add_prompt_to_results
    @mock.expect_completion("The capital of France is ", "Paris.")
    completion = gen("The capital of France is ")

    prompt = "The capital of France is " + gen()
    result = completion + prompt
    assert_equal Instruct::Prompt, result.class
    assert_equal "Paris.The capital of France is 💬", result.to_s
  end

end
