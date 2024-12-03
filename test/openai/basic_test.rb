require "test_helper"
require "ruby/openai"

# These tests could be flakey as they are based on llm responses
class OpenAIBasicTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
  end
  def test_that_it_has_a_version_number
    refute_nil ::OpenAI::VERSION
  end

  def test_completion_api_works
    prompt = "The capital of Australia is Canberra.\n"
    prompt = "The capital of Germany is Berlin.\n"
    prompt += "The capital of France is " + gen
    response = prompt.call(temperature: 0, stop_chars: "\n. ")
    assert_equal "Paris", response.to_s
  end
end
