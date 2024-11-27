require_relative 'test_helper'

class ReadmeTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new
    self._instruct_default_model = @mock
  end

  def test_perform_alternative_call
    # @mock.expect_completion("The capital of France is ", "Paris.")
    # assert_equal "Paris.", gen("The capital of France is ")
    # @mock.verify

    @mock.expect_completion("The capital of France is ", "Paris.")
    ts = "The capital of France is "
    result = gen(ts)
    assert_equal "The capital of France is Paris.", (ts + result).to_s
  end

  def test_perform_single_prompt_call
    @mock.expect_completion("The capital of France is ", "Paris.")
    prompt =  "The capital of France is " + gen()

    assert_equal "The capital of France is 💬", prompt.to_s
    result = prompt.call

    assert_equal "The capital of France is 💬", prompt.to_s
    assert_equal "Paris.", result.to_s
    assert_equal prompt, result.prompt

    together = prompt + result

    assert_equal "The capital of France is 💬", prompt.to_s
    assert_equal "Paris.", result.to_s
    assert_equal prompt, result.prompt

    assert_equal "The capital of France is Paris.", together.to_s

    prompt << result
    assert_equal "The capital of France is Paris.", prompt.to_s

    prompt =  "The capital of France is " + gen()
    assert_equal "The capital of France is 💬", prompt.to_s
    together = prompt + result
    assert_equal "The capital of France is Paris.", together.to_s

    # this shows how a result can be added to a diferrent prompt, and it still works, note however
    # that middleware updates in the result aren't back applied to the original prompt
    prompt =  "The Capital of France is " + gen()
    together = prompt + result
    assert_equal "The Capital of France is Paris.", together.to_s
  end

  def test_perform_multiple_prompt_call
    @mock.expect_completion("The capital of France is ", "Paris")
    @mock.expect_completion("The capital of France is Paris. This is in the region of ", "Europe")
    prompt =  "The capital of France is " + gen() + ". This is in the region of " + gen() + "."
    assert_equal "The capital of France is 💬. This is in the region of 💬.", prompt.to_s
    results = prompt.call
    assert_equal ["Paris", "Europe"], results.map(&:to_s)
    together = prompt + results

    assert_equal "The capital of France is 💬. This is in the region of 💬.", prompt.to_s
    assert_equal ["Paris", "Europe"], results.map(&:to_s)
    assert_equal "The capital of France is Paris. This is in the region of Europe.", together.to_s

    @mock.expect_completion("The capital of France is ", "Paris Oui Oui")
    @mock.expect_completion("The capital of France is Paris. This is in the region of ", "Europe Oui Oui")
    prompt << prompt.call
    assert_equal "The capital of France is Paris Oui Oui. This is in the region of Europe Oui Oui.", prompt.to_s
    @mock.verify
  end

  def test_perform_single_concat
    assert_raises do
      "The capital of France is " << gen()
    end
    @mock.expect_completion("The capital of France is ", "Paris.")
    result = Instruct::Transcript.new("The capital of France is ") << gen()
    assert_equal "The capital of France is Paris.", result.to_s
    @mock.verify
  end

  # def erb_safe_test
  #   ts = erb{"The capital of #{"france"} is <%= gen.capture(:capital) %>. <%= transcript.captured(:capital) %> is a <% gen.capture(:descriptor) %> city."}
  #   "The capital of france is <%= gen.capture(:captial) %>. <%= captured(:capital) %> is a <% gen.capture(:descriptor) %> city."

  #   ts.call
  #   # [ "Paris", "beautiful" ]
  # end



end
