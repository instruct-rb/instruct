module Instruct
 class Gen
   attr_accessor :transcript, :model, :kwargs
   attr_reader :results
   def initialize(transcript:, model:, **kwargs)
     @transcript = transcript
     @model = model
     @kwargs = kwargs
     @results = []
     @capture_key = nil
     @capture_list_key = nil
   end

   def ==(other)
     return false unless other.is_a?(Gen)
     # skip looking at transcript and results for now as it makes two prompts not equal with a gen
     # that has run and one that hasn't
     @model == other.model && @kwargs == other.kwargs
   end

   def capture(key, list: nil)
     @capture_key, @capture_list_key = key, list
     self
   end

   def completed?
     @results.any?
   end

   def call(model: nil, **kwargs, &streaming_block)
     kwargs = @kwargs.merge(kwargs)
     model = Instruct::Model.from_string(model) if model.class == String
     model ||= @model

     completion = Transcript::Completion.new(@transcript.dup)
     transcript = transcript_without_gen_attachment
     request = Gen::CompletionRequest.new(transcript, completion, **kwargs)
     if streaming_block
      request.add_stream_handler do |response|
        set_updated_transcript_on_completion(response, request.transcript)
        set_capture_keys_on_completion(response)
        streaming_block.call(response)
      end
     end
     response = request.execute(model)
     completion_string = response.attributed_string
     set_updated_transcript_on_completion(completion_string, request.transcript)
     set_capture_keys_on_completion(completion_string)
     @results << completion_string
     completion_string
   end

   def transcript_without_gen_attachment
     if @transcript.attachment_at(@transcript.length - 1) == self
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

   def to_s
     if @result.nil?
       "<Instruct::Gen>"
     else
        "<Instruct::Gen call_count=#{result.length}>"
     end
   end

 end
end
