module Instruct::Helpers
 module GenHelper
  def gen(transcript = nil, model: nil, **kwargs)
    if model.nil?
      model = self._instruct_default_model if self.respond_to? :_instruct_default_model
      model ||= 'gpt-3.5-turbo-instruct'
    end
    transcript = Instruct::Transcript.new(transcript) if transcript.class == String
    model = Instruct::Model.from_string(model) if model.class == String
    gen = Instruct::Gen.new(transcript: , model: , **kwargs)
    return gen.call if transcript

    Instruct::Transcript.new.add_attachment(gen)
  end
 end
end
