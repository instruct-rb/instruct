class Instruct::Gemini
  class ChatCompletionResponse < Instruct::Gen::CompletionResponse
    def call(chunk)
      chunk = Instruct::SymbolizeKeys.recursive(chunk)
      case chunk
      # TODO: check if this will break if the content is not text
      in { choices: [ { delta: { content: new_content } } ] }
        append_text_chunk(new_content)
      in { choices: [ { delta: { content: new_content }, finish_reason: } ] }
        append_text_chunk(new_content)
        done(finish_reason) unless finish_reason.nil?
      in { choices: [ { delta: {}, finish_reason: } ] }
        done(finish_reason) unless finish_reason.nil?
      in { choices: [ { delta: { role: } } ] }
      in { error: { message: } }
        raise RuntimeError, "OpenAI Client Error: #{message}"
      else
        raise RuntimeError, "Unexpected Chunk: #{chunk}"
      end
      chunk_processed
    end
  end
end
