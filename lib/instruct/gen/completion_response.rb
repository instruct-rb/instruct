class Instruct::Gen
  # Abstract class for completion responses
  class CompletionResponse

    attr_reader :finished, :finished_reason

    def finished?
      finished
    end

    attr_writer :stream_handlers
    def initialize(stream_handlers: [], completion: )
      @response_buffer = completion
      @stream_handlers = stream_handlers
      @chunks = 0
    end

    # Streaming Response Handlers should override this method
    def call
      raise NotImplementedError
    end

    def append_text_chunk(text_chunk)
      text_chunk = AttributedString.new(text_chunk) unless text_chunk.is_a?(AttributedString)
      text_chunk.add_attrs(stream_chunk: @chunks + 1, source: :llm)
      response_buffer.concat(text_chunk)
    end

    def chunk_processed
      ts = response_buffer
      @stream_handlers.each do |handler|
         ts = handler.call(ts, @chunks)
         break if ts == false
      end
      @response_buffer = ts if ts.is_a? Instruct::Transcript::Completion
      @chunks += 1
    end

    def done(finish_reason)
      @finished = true
      @finished_reason = finish_reason
    end

    def to_s
      response_buffer.to_s
    end

    def attributed_string
      response_buffer
    end
    # def append_function_call
    # end

    private


    # @api private
    # @return [Transcript] the buffer of text
    def response_buffer
      @response_buffer
    end



  end
end
