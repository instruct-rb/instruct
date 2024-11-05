require_relative 'test_helper'

class LMTest < Minitest::Test

  def test_a_prompt_that_doesnt_gen
    lm = Instruct::LM.new
    lm2 = lm + 'a prompt'
    lm3 = lm2 + lm2.f{' with more'} + lm2.f{' and more'}
    assert_equal "", lm.transcript_string
    assert_equal "a prompt", lm2.transcript_string
    assert_equal "a prompt with more and more", lm3.transcript_string

    lm2 += lm2.f{' but not so much'} + lm2.f{' here.'}
    assert_equal "a prompt but not so much here.", lm2.transcript_string
  end

  def test_a_prompt_with_gen
    mock = CompletionMock.new
    lm = Instruct::LM.new(completion_model: mock)
    mock.add_expected_completion("1 + 1 =", " 2", stop: "\n")
    mock.add_expected_completion("1 + 1 =", "2", stop: "\n")
    lm2 = lm + lm.f{'1 + 1 = '} + lm.gen(stop: "\n")
    lm3 = lm + lm.f{'1 + 1 = '} + lm.gen(stop: "\n")
    mock.verify
    assert_equal "1 + 1 = 2", lm2.transcript_string
    assert_equal "1 + 1 = 2", lm3.transcript_string
  end

  def test_a_prompt_with_erb
    mock = CompletionMock.new
    lm = Instruct::LM.new(completion_model: mock)
    mock.add_expected_completion("1 + 1 =", " 2", stop: "\n")
    lm += lm.f{'1 + 1 = <%= gen(stop: "\n") %>.'}
    assert_equal "1 + 1 = 2.", lm.transcript_string
    mock.verify
  end

end
