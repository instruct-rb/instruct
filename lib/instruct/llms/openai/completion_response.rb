class Instruct::OpenAI
  # The completion API has been deprecated from OpenAI but some alternative service providers
  # may still be using it. Leaving it in for now.
  class CompletionResponse < Instruct::Gen::CompletionResponse

    def call(chunk)
      case Instruct::SymbolizeKeys.recursive(chunk)
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
