module Instruct::Model
  class ParseRoles
    def self.parse(*args, **kwargs)
      self.new.parse(*args, **kwargs)
    end

    def initialize
      @roles = [:system, :user, :assistant]
    end

    def call(prompt)
    end

  end
end
