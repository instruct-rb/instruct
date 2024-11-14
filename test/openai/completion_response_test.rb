require_relative '../test_helper'

class OpenAICompletionResponseTeset < Minitest::Test
  def setup
    @client = OpenAI::Client.new(
      access_token: ENV['OPENAI_API_KEY'],
      log_errors: true
    )
  end

  def test_streamed_response
    response = Instruct::OpenAICompletionResponse.new
    client_response = @client.completions(
      parameters: {
        model: "gpt-3.5-turbo-instruct",
        prompt: "What is the capital of Australia?\nThe capital of Australia is Canberra.\nWhat is the capital of France?\n",
        stream: response
      }
    )
    assert_equal response.to_s, "The capital of France is Paris."
    assert response.finished? == true
  end

end
