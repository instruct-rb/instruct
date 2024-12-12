module Instruct::Helpers
 module ModelHelper

   def instruct_default_model
     @_instruct_default_model ||= Instruct.default_model
   end

   def instruct_default_model=(string_or_model)
     @_instruct_default_model = Instruct::Model.from_string_or_model(string_or_model)
   end

 end
end
