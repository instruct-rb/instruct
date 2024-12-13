require_relative '../test_helper'

# These tests could be flakey as they are based on llm responses
class AnthropicBasicTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    self.instruct_default_model = 'claude-3-5-sonnet-latest'
    Instruct.err_logger.sev_threshold = :unknown
  end

  def test_that_it_has_a_version_number
    refute_nil ::Anthropic::VERSION
  end

  def test_messages_completion_api_works
    prompt = "system: you're an alphabet bot\nuser: a b\nassistant: c\n".prompt_safe + gen
    response = prompt.call(temperature: 0, stop_chars: ".", max_tokens: 25)
    assert_equal " d e f g h i j k l m n o p q r s t u v w x y z" , response.to_s
    stop_reason = response.attrs_at(0)[:stop_reason]
    assert_equal "max_tokens", stop_reason
  end

  def test_set_client_opts_in_call
    prompt = "system: you're an alphabet bot\nuser: a b\nassistant: c\n".prompt_safe + gen
    assert_raises Faraday::UnauthorizedError do
      prompt.call(temperature: 0, stop_chars: ".", max_tokens: 25, access_token: 'xx')
    end
  end

  def test_set_client_opts_in_gen
    prompt = "system: you're an alphabet bot\nuser: a b\nassistant: c\n".prompt_safe + gen(access_token: 'xx')
    assert_raises Faraday::UnauthorizedError do
      prompt.call(temperature: 0, stop_chars: ".", max_tokens: 25)
    end
  end

  def test_cannot_set_client_opts_if_model_uses_client
    prompt = "system: you're an alphabet bot\nuser: a b\nassistant: c\n".prompt_safe + gen(beta: 'xx')
    assert_raises ArgumentError do
      prompt.call(model: Instruct::Anthropic.new(::Anthropic::Client.new(access_token: 'xx'), model:'claude-3-5-sonnet-latest') ,temperature: 0, stop_chars: ".", max_tokens: 25)
    end
  end


end
