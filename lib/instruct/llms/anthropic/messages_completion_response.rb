# frozen_string_literal: true

class Instruct::Anthropic
  class MessagesCompletionResponse < Instruct::Gen::CompletionResponse
    @delta_finish_reason = nil

    def call(chunk)
      chunk = Instruct::SymbolizeKeys.recursive(chunk)
      case chunk
      in { type: "message_start" }
        # do nothing
      in { type: "content_block_start", index: _index, content_block: { type: "text", text: chunk }}
          append_text_chunk(chunk)
      in { type: "content_block_delta", index: _index, delta: { type: "text_delta", text: chunk }}
          append_text_chunk(chunk)
      in { type: "content_block_stop", index: _index }
          # do nothing
      in { type: "message_delta", delta: { stop_reason: } }
          # this occurs just before the message_stop and lets us collect the stop reason (and other info like output tokens)
          @delta_finish_reason = stop_reason
      in { type: "message_stop" }
        done(@delta_finish_reason)
      in { type: "ping" }
        # do nothing
      in { error: { message: , type: } }
        raise RuntimeError, "Anthropic Client Error: (type: #{type}, message: #{message})"
      else
        raise RuntimeError, "Unexpected Chunk: #{chunk}"
      end
      chunk_processed
    end


  end
end
