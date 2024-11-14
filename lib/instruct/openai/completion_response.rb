module Instruct
  class OpenAICompletionResponse < Model::CompletionResponse

    def call(chunk)
      case SymbolizeKeys.recursive(chunk)
      in { choices: [ { text: new_content, finish_reason: } ] }
        append_text_chunk(new_content)
        done(finish_reason) unless finish_reason.nil?
      in { error: { message: } }
        raise RuntimeError, "OpenAI Client Error: #{message}"
      else
        raise RuntimeError, "Unexpected Chunk: #{chunk}"
      end
      chunk_processed
    end

  end
end
