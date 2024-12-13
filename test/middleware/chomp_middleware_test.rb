require_relative '../test_helper'

class ChompMiddlewareTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new(middlewares: [Instruct::ChompMiddleware])
    self.instruct_default_model = @mock
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

  def test_that_a_prompt_is_chomped_but_the_reponse_has_whitespace_added
    @mock.expect_completion("a prompt:", "a response")
    prompt = Instruct::Transcript.new << "a prompt: " + gen()
    @mock.verify
    assert_equal "a prompt: a response", prompt.prompt_object.to_s
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

  def test_double_chomp_and_capture_works_as_expected
    mock = MockCompletionModel.new(middlewares: [Instruct::ChompMiddleware])
    mock.expect_completion("Please think of 2 different animals on separate lines.\nAnimal 1:", "Zebra", stop: "\n")
    mock.expect_completion("Please think of 2 different animals on separate lines.\nAnimal 1: Zebra\nAnimal 2:", "Lion", stop: "\n")
    self.instruct_default_model = mock

    lm = p{'Please think of 2 different animals on separate lines.'}
    2.times do |i|
      lm << "\nAnimal #{i+1}: ".prompt_safe
      lm << gen(stop: "\n").capture(:animal, list: :animals)
    end
    mock.verify
    assert_equal "Please think of 2 different animals on separate lines.\nAnimal 1: Zebra\nAnimal 2: Lion", lm.to_s
    assert_equal ["Zebra", "Lion"], lm.captured(:animals)
    assert_equal "Lion", lm.captured(:animal)
  end
end
