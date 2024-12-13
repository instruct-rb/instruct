require "test_helper"
require "ruby/openai"

# These tests could be flakey as they are based on llm responses
class OpenAIBasicTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    self.instruct_default_model = 'gpt-4o-mini'
    Instruct.err_logger.sev_threshold = :unknown
  end

  def test_completion_api_works
    prompt = "The capital of Australia is Canberra.\n"
    prompt = "The capital of Germany is Berlin.\n"
    prompt += "The capital of France is " + gen
    response = prompt.call(temperature: 0, stop_chars: "\n. ", model: 'gpt-3.5-turbo-instruct')
    assert_equal "Paris", response.to_s
  end

  def test_that_it_has_a_version_number
    refute_nil ::OpenAI::VERSION
  end

  def test_cant_use_completion_model_with_chat_gpt_model
    prompt = "system: you're an alphabet bot\nuser: ab\nassistant: c\n" + gen
    assert_raises Faraday::ResourceNotFound do
      prompt.call(temperature: 0, stop_chars: "\n. ", model: 'gpt-3.5-turbo', use_completion_endpoint: true)
    end
  end

  def test_set_client_opts_in_gen
    prompt = "system: you're an alphabet bot\nuser: a b\nassistant: c\n".prompt_safe + gen(access_token: 'xx')
    assert_raises Faraday::UnauthorizedError do
      prompt.call(temperature: 0, stop_chars: ".", max_tokens: 25)
    end
  end

  def test_cannot_set_client_opts_if_model_uses_client
    prompt = "system: you're an alphabet bot\nuser: a b\nassistant: c\n".prompt_safe + gen(response_timeout: 100)
    assert_raises ArgumentError do
      prompt.call(model: Instruct::OpenAI.new(::OpenAI::Client.new(access_token: 'xx'), model:'gpt-4o-mini') ,temperature: 0, stop_chars: ".", max_tokens: 25)
    end
  end

  def test_chat_completion_api_works
    prompt = "system: you're an alphabet bot\nuser: ab\nassistant: c\n" + gen
    response = prompt.call(temperature: 0, stop_chars: "\n. ", model: 'gpt-3.5-turbo')
    assert_equal "d", response.to_s
  end

  def test_serialized_model_works
    prompt = "system: you're an alphabet bot\nuser: ab\nassistant: c\n" + gen
    prompt = Instruct::Serializer.load(Instruct::Serializer.dump(prompt))
    response = prompt.call(temperature: 0, stop_chars: "\n. ", model: 'gpt-3.5-turbo')
    assert_equal "d", response.to_s
  end
end
