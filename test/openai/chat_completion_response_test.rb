require_relative '../test_helper'

class OpenAIChatCompletionResponseTeset < Minitest::Test
  def setup
    @client = OpenAI::Client.new(
      access_token: ENV['OPENAI_API_KEY'],
      log_errors: true
    )
  end

  def test_streamed_response
    response = Instruct::OpenAIChatCompletionResponse.new
    client_response = @client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "You're a helpful assistant. Please answer questions about capital cities and respond in the format 'The capital of X is Y.'" },
          { role: "user", content: "What's the capital of France?"}
        ],
        stream: response
      }
    )
    assert_equal response.to_s, "The capital of France is Paris."
    assert response.finished? == true
  end

end
