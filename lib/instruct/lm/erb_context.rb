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
      # TODO: wrap this call add it to the transcript as unsafe, clear the buffer and return nil
      if @binding.local_variables.include?(name)
        @binding.local_variable_get(name)
      elsif @lm.respond_to?(name)
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
