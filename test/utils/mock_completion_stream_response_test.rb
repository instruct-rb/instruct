require_relative "../test_helper"
require_relative "mock_completion_stream_response"

class MockCompletionStreamResponseTest < Minitest::Test
  def test_that_it_chunks_text_up
    mock = MockCompletionStreamResponse.new("some longish text that will be chunked up")
    assert mock.stream_chunks.size > 1
    assert mock.stream_chunks.last[:finish_reason] = :stop
  end

  def test_that_its_randomly_chunking
    mock1 = MockCompletionStreamResponse.new("some longish text that will be chunked up, it's long enough that random will mean this test is very unlikely to fail")
    mock2 = MockCompletionStreamResponse.new("some longish text that will be chunked up, it's long enough that random will mean this test is very unlikely to fail")
    assert mock1.stream_chunks == mock1.stream_chunks.dup
    assert mock1.stream_chunks != mock2.stream_chunks
  end

  def test_that_after_streaming_the_string_is_complete
    mock = MockCompletionStreamResponse.new("some longish text that will be chunked up")
    mock.simulate_streaming
    assert_equal "some longish text that will be chunked up", mock.to_s
  end

  def test_that_the_finished_reason_is_stop
    mock = MockCompletionStreamResponse.new("some longish text that will be chunked up")
    mock.simulate_streaming
    assert_equal :stop, mock.finished_reason
  end

  def test_that_the_finish_reason_shows
    mock = MockCompletionStreamResponse.new("some text", finish_reason: :max_tokens)
    mock.simulate_streaming
    assert_equal :max_tokens, mock.finished_reason
  end

  def test_takes_an_array_for_custom_chunking
    chunks = ["some ", "text ", "with ", "cus", "tom chunks"]
    mock = MockCompletionStreamResponse.new(chunks)

    # poor test: it's testing the implementation, not the behavior
    mock.stream_chunks.each_with_index do |chunk, idx|
      assert_equal chunks[idx], chunk[:text_chunk]
    end
  end

end
