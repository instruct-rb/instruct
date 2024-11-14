module Instruct
  module SymbolizeKeys
    class << self
      def recursive(hash)
        {}.tap do |h|
          hash.each { |key, value| h[key.to_sym] = map_value(value) }
        end
      end

      def map_value(thing)
        case thing
        when Hash
          recursive(thing)
        when Array
          thing.map { |v| map_value(v) }
        else
          thing
        end
      end
    end
  end
end
