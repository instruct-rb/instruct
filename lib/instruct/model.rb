module Instruct
  module Model
    def self.included(base)
      # add @middlewares = [] to the base class
      base.instance_variable_set(:@middlewares, [])
      base.attr_reader :middlewares
    end



  end
end
