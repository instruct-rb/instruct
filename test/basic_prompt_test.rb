require_relative "test_helper"

class BasicPromptTest < Minitest::Test

  def setup
    @mock = MockCompletionModel.new
    @lm = Instruct::LM.new(completion_model: @mock)
  end


  def test_a_two_part_basic_prompt
    @mock.expect_completion("a prompt:", " a response", stop: "\n")
    @mock.expect_completion("a prompt: a response and a", "nother response", stop: "\n")
    @lm += @lm.f{'a prompt: <%= gen(stop: "\n") %> and a <%= gen(stop: "\n") %>'}
    @mock.verify
  end

  def test_a_basic_prompt_extra_gen
    @mock.expect_completion("a prompt:", " a response", stop: "\n")
    @lm += @lm.f{'a prompt: '}
    @lm += @lm.gen(stop: "\n")
    @mock.verify
  end

end
