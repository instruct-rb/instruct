module Instruct::Helpers
  module GenHelper
    # This helper is used to create a new Instruct::Gen object. It can be used in
    # two ways: with a transcript or without. If a transcript is provided, the
    # method will immediately return the generated completion. If no transcript
    # is provided, the method will return a deferred completion that can be
    # appended to a transcript.
    # @param transcript [Instruct::Transcript, String, nil] The transcript to generate a completion for.
    # @param model [Instruct::Model, String, nil] The model to use for generation.
    # @param client_opts [Hash] Optional keyword argument that contains an option hash to pass to the API client when initializing a client model with a string.
    def gen(transcript = nil, model: nil, **kwargs)

      transcript = Instruct::Transcript.new(transcript) if transcript.class == String
      model ||= self.respond_to?(:instruct_default_model) ? self.instruct_default_model : nil
      gen = Instruct::Gen.new(transcript: , model: , **kwargs)

      return gen.call if transcript

      Instruct::Transcript.new.add_attachment(gen)
    end
  end
end
