module Instruct
 class Gen
   include Instruct::Serializable
   set_instruct_class_id 2

   attr_accessor :prompt, :model, :gen_kwargs
   attr_accessor :capture_key, :capture_list_key
   attr_reader :results
   def initialize(prompt:, model:, **kwargs)
     @prompt = prompt
     @model = model
     @gen_kwargs = kwargs
     @results = []
     @capture_key = nil
     @capture_list_key = nil
   end


   def ==(other)
     return false unless other.is_a?(Gen)
     # skip looking at prompt and results for now as it makes two prompts not equal with a gen
     # that has run and one that hasn't
     return false if @gen_kwargs != other.gen_kwargs
     return false if @model.is_a?(String) && other.model.is_a?(String) && @model != other.model
     return @model.class == other.model.class
   end

   def capture(key, list: nil)
     @capture_key, @capture_list_key = key, list
     self
   end

   def completed?
     @results.any?
   end

   # This is the method that actually calls the LLM API with the prompt and creates a completion
   # @param model this is a model object or the name of a model.
   # @param client_opts: this is an optional hash of options to pass to the API client when initializing a client model with a string
   # @block streaming_block: this is an optional block that will be called with each chunk of the response when the response is streamed
   def call(model: nil, **call_kwargs, &streaming_block)
     gen_and_call_kwargs = gen_kwargs.merge(call_kwargs)
     model = select_first_model_from(model, @model, Instruct.default_model, gen_and_call_kwargs:)

     generate_completion = Instruct::GenerateCompletion.new(prompt:, model:, capture_key:, capture_list_key:, streaming_block:, gen_and_call_kwargs: )
     completion = generate_completion.call(calling_gen: self)

     @results << completion
     completion
   end


   def to_s
     if @result.nil?
       "<Instruct::Gen>"
     else
        "<Instruct::Gen call_count=#{result.length}>"
     end
   end

   private

   def select_first_model_from(*args, gen_and_call_kwargs:)
     model = args.compact.first
     model = Instruct::Model.from_string(model, **gen_and_call_kwargs) if model.is_a?(String)
     model
   end

 end
end
