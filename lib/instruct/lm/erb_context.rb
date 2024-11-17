class Instruct::LM
  class ERBContext
    attr_reader :unsafe
    def initialize(lm, binding, expression, safe)
      @lm = lm
      @expression = expression
      @unsafe = SecureRandom.hex(12)
      @binding = binding
      @_erbout = ''  # Use ERB's default output buffer variable
    end

    def unsafe_print(string)
      # TODO: this doesn't work
      # Follow https://yehudakatz.com/2010/02/01/safebuffers-and-rails-3-0/
      # Once attributed strings have append, we'll just make the safebuffer an attributed string
      if string.is_a?(LMSafe)
      # this will work if safe is defined at the lm level, we can then add a safe_code that stops the unsafe code
        @_erbout.<< string
      else
        @_erbout.<< unsafe
        @_erbout.<< string
        @_erbout.<< unsafe
      end
    end

    # Expose methods and variables to the ERB template
    def method_missing(name, *args, &block)
      if @binding.local_variables.include?(name)
        @binding.local_variable_get(name)
      elsif name == :gen
        @lm.send(name, *args, &block)
      else
        super
      end
    end

    def gen(**kwargs)
      kwargs[:_instruct_erb_context] = [@_erbout.dup, @expression, @unsafe]
      @_erbout.clear
      @lm.gen(**kwargs)
    end

    # No need for custom concat method
  end
end
