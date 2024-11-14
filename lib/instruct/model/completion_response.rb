module Instruct::Model
  # Abstract class for completion responses
  class CompletionResponse

    attr_reader :finished, :finished_reason

    def finished?
      finished
    end

    def initialize
      @chunks = 0
      reset_last_chunk_ranges
    end

    # Streaming Response Handlers should override this method
    def call
      raise NotImplementedError
    end

    def append_text_chunk(text_chunk)
      range = response_buffer.append_and_get_new_range(text_chunk)
      response_buffer.add_attributes(range, { chunk: @chunks + 1 })
      @last_chunk_ranges << range
    end

    def chunk_processed
      @chunks += 1
      reset_last_chunk_ranges
    end

    def done(finish_reason)
      @finished = true
      @finished_reason = finish_reason
    end

    def to_s
      response_buffer.string
    end

    def attributed_string
      response_buffer
    end
    # def append_function_call
    # end

    private

    def reset_last_chunk_ranges
      @last_chunk_ranges = []
    end

    # @api private
    # @return [Instruct::AttributedString] the buffer of text
    def response_buffer
      @response_buffer ||= Instruct::AttributedString.new
    end



  end
end
