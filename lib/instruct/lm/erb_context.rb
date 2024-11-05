class Instruct::LM
  class ERBContext
    def initialize(lm, binding)
      @lm = lm
      @binding = binding
      @_erbout = ''  # Use ERB's default output buffer variable
    end

    # Expose methods and variables to the ERB template
    def method_missing(name, *args, &block)
      if @binding.local_variables.include?(name)
        @binding.local_variable_get(name)
      elsif @lm.respond_to?(name)
        @lm.send(name, *args, &block)
      else
        super
      end
    end

    def gen(**kwargs)
      kwargs[:partial_output] = @_erbout.gsub!(/ +$/,'').dup
      # llms cant accept a trailing space, so whenever we run gen, we remove it
      @lm.gen(**kwargs)
    end

    # No need for custom concat method
  end
end
