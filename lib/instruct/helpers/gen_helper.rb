module Instruct::Helpers
  module GenHelper
    # This helper is used to create a new Instruct::Gen object. It can be used in
    # two ways: with a prompt or without. If a prompt is provided, the
    # method will immediately return the generated completion. If no prompt
    # is provided, the method will return a deferred completion that can be
    # appended to a prompt.
    # @param prompt [Instruct::Prompt, String, nil] The prompt to generate a completion for.
    # @param model [Instruct::Model, String, nil] The model to use for generation.
    # @param client_opts [Hash] Optional keyword argument that contains an option hash to pass to the API client when initializing a client model with a string.
    def gen(prompt = nil, model: nil, **kwargs)

      prompt = Instruct::Prompt.new(prompt) if prompt.class == String
      model ||= self.respond_to?(:instruct_default_model) ? self.instruct_default_model : nil
      gen = Instruct::Gen.new(prompt: , model: , **kwargs)

      return gen.call if prompt

      Instruct::Prompt.new.add_attachment(gen)
    end
  end
end
