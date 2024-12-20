require_relative 'test_helper'

class LLMCompletionsTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new
    self.instruct_default_model = @mock
  end

  def test_perform_alternative_call
    @mock.expect_completion("The capital of France is ", "Paris.")
    assert_equal "Paris.", gen("The capital of France is ")
    @mock.verify

    @mock.expect_completion("The capital of France is ", "Paris.")
    prompt = "The capital of France is "
    result = gen(prompt)
    assert_equal "The capital of France is Paris.", (prompt + result).to_s
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
    @mock.expect_completion("The capital of France is Paris Oui Oui. This is in the region of ", "Europe Oui Oui")
    prompt << prompt.call
    assert_equal "The capital of France is Paris Oui Oui. This is in the region of Europe Oui Oui.", prompt.to_s
    @mock.verify
  end

  def test_result_adds_in_correctly_in_two_part_string_with_double_arrow
    @mock = MockCompletionModel.new(middlewares: [Instruct::ChatCompletionMiddleware])
    self.instruct_default_model = @mock
    @mock.expect_completion({ messages: [ { user: "The capital of France is".prompt_safe } ]}, "Paris")
    prompt = Instruct::Prompt.new
    prompt << p{"user: The capital of France is"} + gen.capture(:france) + "\n"
    @mock.verify
    assert_equal "Paris", prompt.captured(:france).to_s
    assert_equal "user: The capital of France is\nassistant: Paris\n", prompt.to_s
  end

  def test_adds_two_gens_in_correctly_on_updated_transcript
    @mock = MockCompletionModel.new(middlewares: [Instruct::ChatCompletionMiddleware])
    self.instruct_default_model = @mock
    @mock.expect_completion({ messages: [ { user: "The capital of France is".prompt_safe } ]}, "Paris")
    @mock.expect_completion(nil, "Berlin")
    prompt = Instruct::Prompt.new
    prompt << p{"user: The capital of France is"} + gen.capture(:france) + "\n".prompt_safe + p{"user: The capital of Germany is"} + gen.capture(:germany) + "\n".prompt_safe
    @mock.verify
    assert_equal "Paris", prompt.captured(:france).to_s
    assert_equal "Berlin", prompt.captured(:germany).to_s
    expected = <<~TT
      user: The capital of France is
      assistant: Paris
      user: The capital of Germany is
      assistant: Berlin
    TT
    assert_equal expected, prompt.to_s
  end

  def test_perform_single_concat
    assert_raises do
      "The capital of France is " << gen()
    end
    @mock.expect_completion("The capital of France is ", "Paris.")
    result = Instruct::Prompt.new("The capital of France is ") << gen()
    assert_equal "The capital of France is Paris.", result.to_s
    @mock.verify
  end

  def test_p_helpers
    some_context = "test"
    _ = some_context # silence unused variable warning
    prompt = p.system{"s <%= some_context %>"}
    prompt << p.user{"u <%= some_context %>"}
    prompt << p.assistant{"a <%= some_context %>"}
    assert_equal "\nsystem: s test\nuser: u test\nassistant: a test", prompt.to_s
  end

  def test_conversation_example
    @mock.expect_completion(nil, "hello")
    7.times do |i|
      @mock.expect_completion(nil, "p#{i}")
      @mock.expect_completion(nil, "i#{i}")
    end
    @mock.expect_completion(nil, "bye")
    pop_star = "Noel Gallagher"
    pop_star = p{"system: You're <%= pop_star %>. You are being interviewed, each message from the user is from an interviewer"}
    interviewer = p{"system: You're an expert interviewer, each message is from the pop star you're interviewing"}
    interviewer << p{"user: [<%= pop_star %> sits down in front of you]"} + gen

    7.times do
      pop_star << p{"user: <%= interviewer.captured(:reply) %>"} + gen.capture(:reply, list: :replies)
      interviewer << p{"user: <%= pop_star.captured(:reply) %>"} + gen.capture(:reply, list: :replies)
    end

    interviewer << p{"user: <%= pop_star.captured(:reply) %> I've got to head off now."} + gen.capture(:reply, list: :replies)
    @mock.verify
    conversation = pop_star.captured(:replies).zip(interviewer.captured(:replies)).flatten.join("")
    expected = "p0i0p1i1p2i2p3i3p4i4p5i5p6i6"
    assert_equal expected, conversation

  end

  class ERBTestClass
    include Instruct::Helpers::ERBHelper
    def test_method
      "test"
    end
    def create_prompt
      p{"user: <%= test_method %>"}
    end
  end

  def test_erb_helper_accesses_methods
    erb = ERBTestClass.new
    assert_equal "user: test", erb.create_prompt
  end

end
