class Instruct::CompileERB
  using AttributedString::Refinements
  # This class needs to only have methods that are used within the ERB
  # scope as otherwise they will be called by the ERB template instead
  # of local vars.
  def initialize(erb_future:, lm:, file:, line:, template:, _binding:, &result)
    super()
    @lm = lm
    @erb_future = erb_future
    @future_expressions = []
    @binding = _binding
    @result_block = result
    @_erbout = TranscriptString.new('')

    compiler = ERB::Compiler.new('-')
    compiler.put_cmd = "@_erbout.safe_concat"
    compiler.insert_cmd = "@_erbout.concat"
    compiler.pre_cmd = ["@_erbout = + TranscriptString.new('')"]
    compiler.post_cmd = ["@_erbout"]

    src, _, _ = compiler.compile(template)

    output = eval(src, binding, '(erb without file)', 0)

    @result_block.call(output)
  end

  def raw(string)
    @_erbout.safe_concat(string)
    ""
  end

  # Expose methods and variables to the ERB template
  def method_missing(name, *args, &block)
    if @binding.local_variables.include?(name)
      @binding.local_variable_get(name)
    else
      super
    end
  end

  def gen(**kwargs)
    transcript = @lm.transcript + @_erbout
    @result_block.call(@_erbout)
    @_erbout.clear
    ts = @erb_future.gen(transcript: transcript, **kwargs)
    @result_block.call(ts)
    ""
  end

  def captured(name)
    @lm[name]
  end

    # No need for custom concat method
end
