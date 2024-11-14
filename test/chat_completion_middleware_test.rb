require_relative "test_helper"
require "ostruct"

class ChatCompletionMiddlewareTest < Minitest::Test
  def completion_request(expression)
    mock = CompletionMock::ModelMock.new
    result = nil
    mock.expect(:execute, "2") do |args|
      result = args
    end
    lm = Instruct::LM.new(completion_model: mock)
    lm += expression
    result
  end


  def test_it_switches_roles
    skip
    lm = Instruct::LM.new(completion_model: nil)

    req = completion_request(lm.f{<<~ERB
      System: You're a helpful assistant
      User: I need help
      Assisant: I can help you with that
      User: What's 1 + 1?
      Assistant: <%= gen(stop: "\n") %>
    ERB
    })

    old_transcript = req.transcript.dup

    result = nil
    Instruct::Model::ChatCompletionMiddleware.new.call(req, _next: -> (new_req) { result = new_req; "" })

    expected = [
      [{ system: "You're a helpful assistant" }],
      [{ user: "I need help" }],
      [{ assistant: "I can help you with that" }],
      [{ user: "What's 1 + 1?" }],
      [{ assistant: "2" }],
    ]

    old_transcript.elements.each_with_index do |element, i|
      element.content = expected[i]
      element.content[0][:mime] = 'plain/text'
      element.mime_type = "instruct/chat_elements"
    end


    assert_equal old_transcript.elements.map(&:to_h), result.transcript.elements.map(&:to_h)
  end
end
