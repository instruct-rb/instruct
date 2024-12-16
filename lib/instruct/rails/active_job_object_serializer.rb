require "active_job"

module Instruct::Rails
  class ActiveJobObjectSerializer < ActiveJob::Serializers::ObjectSerializer
    def self.serialize(transcript)
      super({"value" => Instruct::Serializer.dump(transcript)})
    end

    def self.deserialize(hash)
      Instruct::Serializer.load(hash["value"])
    end

    def self.serialize?(object)
      # Allow transcripts and completions to be serialized
      return true if object.is_a?(Instruct::Transcript) || object.is_a?(Instruct::Transcript::Completion)

      # Allow models to be serialized
      return true if Instruct.openai_loaded && object.is_a?(OpenAI)
      return true if Anthropic.anthropic_loaded && object.is_a?(Anthropic)
      false
    end
  end
end
