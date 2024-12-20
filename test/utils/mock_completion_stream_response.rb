class MockCompletionStreamResponse < Instruct::Gen::CompletionResponse

  def self.text_chunk(text_chunk, finish_reason: nil)
    return { text_chunk: text_chunk, finish_reason: self.finish_reason(finish_reason) } if finish_reason
    { text_chunk: text_chunk }
  end

  def self.finish_reason(arg)
    { finish_reason: arg }
  end


  attr_reader :stream_chunks
  def initialize(text = nil, stream_chunks: nil, finish_reason: nil, completion: Instruct::Transcript::Completion.new(prompt: Instruct::Transcript.new), **kwargs)
    if text.is_a?(Array)
      stream_chunks = text.map { |chunk| self.class.text_chunk(chunk) }
      stream_chunks.last[:finish_reason] = finish_reason || :stop
      finish_reason = nil
      text = nil
    end
    raise ArgumentError, "text and stream_chunks cannot both be nil" if text.nil? && stream_chunks.nil?
    raise ArgumentError, "text and stream_chunks cannot both be present" if text && stream_chunks
    raise ArgumentError, "finish_reason can't be present if stream_chunks is present" if stream_chunks && finish_reason
    @pos = 0
    @stream_chunks = stream_chunks
    if text
      # split the text into chunks randomly 2-5 characters long
      while text.length > 0
        chunk_length = rand(2..5)
        chunk = text.slice!(0, chunk_length)
        @stream_chunks ||= []
        @stream_chunks << self.class.text_chunk(chunk)
      end
      @stream_chunks.last[:finish_reason] = finish_reason || :stop
    end
    super(completion: completion, **kwargs)
  end

  def simulate_streaming
    while @pos < @stream_chunks.length
      chunk = @stream_chunks[@pos]
      append_text_chunk(chunk[:text_chunk]) if chunk[:text_chunk]
      chunk_processed
      if chunk[:finish_reason]
        done chunk[:finish_reason]
        break
      end
      @pos += 1
    end
  end

end
