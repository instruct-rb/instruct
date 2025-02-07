require "test_helper"
require "ruby/openai"

# These tests could be flakey as they are based on llm responses
class OpenAIBasicTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    self.instruct_default_model = "gemini-1.5-flash"
    Instruct.logger.sev_threshold = :unknown
    Instruct.err_logger.sev_threshold = :unknown
  end


  def test_set_client_opts_in_gen
    prompt = "system: you're an alphabet bot\nuser: a b c".prompt_safe + gen(access_token: "xx")
    assert_raises Faraday::BadRequestError do
      prompt.call(temperature: 0, stop_chars: ".", max_tokens: 25)
    end
  end

  def test_cannot_set_client_opts_if_model_uses_client
    prompt = "system: you're an alphabet bot\nuser: a b c\n".prompt_safe + gen(response_timeout: 100)
    assert_raises ArgumentError do
      prompt.call(model: Instruct::Gemini.new(::OpenAI::Client.new(access_token: "xx"), model: "gpt-4o-mini"), temperature: 0, stop_chars: ".", max_tokens: 25)
    end
  end

  def test_chat_completion_api_works_with_gemini
    prompt = "system: you're an alphabet bot just say the next character\nuser: a b c ".prompt_safe + gen
    response = prompt.call(temperature: 0.1, max_tokens: 1, stop_chars: "\n.")
    assert_equal "d", response.to_s
  end

  def test_serialized_model_works
    prompt = "system: you're an alphabet bot jus say the next character\nuser: a b c ".prompt_safe + gen
    prompt = Instruct::Serializer.load(Instruct::Serializer.dump(prompt))
    response = prompt.call(temperature: 0, stop_chars: "\n. ")
    assert_equal "d", response.to_s
  end
end
