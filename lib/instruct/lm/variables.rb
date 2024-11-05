# Provides a simple hash-like interface for storing variables in LM.
class Instruct::LM
  module Variables
    attr_reader :variables

    def [](key)
      @variables[key]
    end

    private

    def []=(key, value)
      @variables[key] = value
    end

    def initialize_variables(variables = {})
      @variables = variables.dup
    end
  end
end
