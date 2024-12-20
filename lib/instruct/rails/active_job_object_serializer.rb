require "active_job"

module Instruct::Rails
  class ActiveJobObjectSerializer < ActiveJob::Serializers::ObjectSerializer
    def self.serialize(prompt)
      super({"value" => Instruct::Serializer.dump(prompt)})
    end

    def self.deserialize(hash)
      Instruct::Serializer.load(hash["value"])
    end

    def self.serialize?(object)
      # Allow prompts and completions to be serialized
      return true if object.is_a?(Instruct::Prompt) || object.is_a?(Instruct::Prompt::Completion)

      # Allow models to be serialized
      return true if Instruct.openai_loaded && object.is_a?(OpenAI)
      return true if Anthropic.anthropic_loaded && object.is_a?(Anthropic)
      false
    end
  end
end
