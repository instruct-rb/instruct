module Instruct::Helpers
 module GenHelper
  def gen(transcript = nil, model: self._instruct_default_model, **kwargs)
    transcript = Instruct::Transcript.new(transcript) if transcript.class == String
    gen = Instruct::Gen.new(transcript: , model: , **kwargs)
    return gen.call if transcript

    Instruct::Transcript.new.add_attachment(gen)
  end
 end
end
