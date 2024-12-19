module Instruct
  class GenerateCompletion
    def initialize(transcript:, model:, streaming_block:nil, capture_key:, capture_list_key:, env: {})
      @transcript = transcript
      @model = model
      @streaming_block = streaming_block
      @capture_key = capture_key
      @capture_list_key = capture_list_key
      @env = env
    end

    def call(calling_gen:)
      completion = Transcript::Completion.new(duped_transcript: @transcript.dup)
      transcript = transcript_with_gen_attachment_removed(calling_gen)
      env = build_request_env
      request = Gen::CompletionRequest.new(transcript, completion, **env)
      if @streaming_block
      request.add_stream_handler do |response|
        set_updated_transcript_on_completion(response, request.transcript)
        set_capture_keys_on_completion(response)
        @streaming_block.call(response)
      end
      end
      response = request.execute(@model)
      completion_string = response.attributed_string
      set_updated_transcript_on_completion(completion_string, request.transcript)
      set_capture_keys_on_completion(completion_string)
      completion_string
    end

    private

    def build_request_env
      @model.default_request_env.merge(@env)
    end

    def transcript_with_gen_attachment_removed(calling_gen)
      if calling_gen && @transcript.attachment_at(@transcript.length - 1) == calling_gen
        @transcript[...-1]
      else
        @transcript.dup
      end
    end

    def set_updated_transcript_on_completion(completion, transcript)
      completion.send(:updated_transcript=, transcript.dup)
    end

    def set_capture_keys_on_completion(completion)
      completion.send(:captured=, @capture_key, @capture_list_key)
    end
  end
end
