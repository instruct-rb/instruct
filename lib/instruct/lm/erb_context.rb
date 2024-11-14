class Instruct::LM
  class ERBContext
    def initialize(lm, binding, expression)
      @lm = lm
      @expression = expression
      @binding = binding
      @_erbout = ''  # Use ERB's default output buffer variable
    end

    # Expose methods and variables to the ERB template
    def method_missing(name, *args, &block)
      if @binding.local_variables.include?(name)
        plain_text = Instruct::Expression::PlainText.new(@_erbout.dup, prompt_safe: @expression.should_mark_child_plain_text_as_prompt_safe?)
        @lm.process_expression(plain_text, user_expression: @expression)
        @_erbout.clear
        string = @binding.local_variable_get(name)
        # we should have a way to mark as prompt safe
        plain_text = Instruct::Expression::PlainText.new(string.to_s, prompt_safe: false)
        @lm.process_expression(plain_text, user_expression: @expression)
        @_erbout.clear
      elsif name == :gen
        @lm.send(name, *args, &block)
      else
        super
      end
    end

    def gen(**kwargs)
      kwargs[:_instruct_erb_context] = [@_erbout.dup, @expression]
      @_erbout.clear
      @lm.gen(**kwargs)
    end

    # No need for custom concat method
  end
end
