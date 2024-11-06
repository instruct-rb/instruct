# Provides a simple hash-like interface for storing variables in LM.
class Instruct::LM
  module Variables
    attr_reader :variables

    def [](key)
      raise ArgumentError, "key must not be nil" if key.nil?
      key = key.to_sym
      @variables[key]
    end

    private

    def []=(key, value)
      key = key.to_sym
      @variables[key] = value
    end

    def capture_result_in_variable(response, arr_name: nil, name: nil)
      if arr_name
        self[arr_name] ||= []
        self[arr_name] << response
      end
      if name
        self[name] = response
      end
    end

    def dup_variables
      @variables.dup
    end

    def initialize_variables(variables = {})
      @variables = variables.dup
    end
  end
end
