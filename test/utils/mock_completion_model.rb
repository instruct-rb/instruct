# A mock class used to simulate a completion model such as gpt-3.5-turbo-instruct.
class MockCompletionModel


  def initialize(middlewares: [])
    @position = 0
    @expected_calls = []
    @middlewares = middlewares
  end

  def expect_completion(expected_prompt_or_nil, text_or_mock_stream_response, finish_reason: :stop, **kwargs)
    @expected_calls << { expected_prompt: expected_prompt_or_nil, kwargs:, response: text_or_mock_stream_response, finish_reason: }
  end

  def middleware_chain
    @chain ||= Instruct::MiddlewareChain.new(middlewares: @middlewares + [self])
  end

  def call(req, _next:)
    if @position >= @expected_calls.length
      raise MockExpectationError, "Expected no more completion calls, but got: '#{req}'"
    end

    prompt = req.prompt_object
    expected_prompt = @expected_calls[@position][:expected_prompt]
    if expected_prompt.nil? && prompt != @expected_calls[@position][:expected_prompt]
      raise MockExpectationError, "Expected prompt: '#{@expected_calls[@position][:expected_prompt]}', but got: '#{prompt}'"
    end

    expected_kwargs = @expected_calls[@position][:kwargs]
    expected_kwargs.each do |key, value|
      if req.env[key] != value
        raise MockExpectationError, "Expected env key '#{key}' to be '#{value}', but got '#{req.env[key]}'"
      end
    end

    response = @expected_calls[@position][:response]
    if response.is_a?(String)
      response = MockCompletionStreamResponse.new(response, finish_reason: @expected_calls[@position][:finish_reason])
    elsif response.is_a?(MockCompletionStreamResponse)
    else
      raise ArgumentError, "Expected response to be a string or MockCompletionStreamResponse, but got: '#{response}'"
    end

    response.simulate_streaming
    @position += 1

    response
  end

  def verify
    if @position != @expected_calls.length
      raise MockExpectationError, "Expected #{@expected_calls.length} completion calls, but got #{@position}"
    end
  end

end
