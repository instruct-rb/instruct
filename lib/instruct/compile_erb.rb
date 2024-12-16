module Instruct
  class CompileERB
    # TODO: consider including the following refinements as they might be able to be used within the erb block
    # needs tests before including
    #
    # using AttributedString::Refinements
    # using Instruct::Refinements
    # include Instruct::Helpers::GenHelper

    # This class needs to only have methods that are used within the ERB
    # scope as otherwise they will be called by the ERB template instead
    # of local vars.
    def initialize(template:, _binding:)
      @binding = _binding
      @_erbout = Transcript.new
      compiler = ERB::Compiler.new('-')
      compiler.put_cmd = "@_erbout.safe_concat"
      compiler.insert_cmd = "@_erbout.concat"
      compiler.pre_cmd = ["@_erbout = + Transcript.new('')"]
      compiler.post_cmd = ["@_erbout"]

      src, _, _ = compiler.compile(template)

      @output = eval(src, binding, '(erb without file)', 0)
    end

    def raw(string)
      @_erbout.safe_concat(string)
      ""
    end

    # Expose methods and variables to the ERB template
    def method_missing(name, *args, &block)
      if @output && name == :transcript
        @output
      elsif @binding.local_variables.include?(name)
        @binding.local_variable_get(name)
      else
        @binding.eval(name.to_s)
      end
    end

  end
end
