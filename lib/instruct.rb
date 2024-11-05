# depenedencies
require_relative "instruct/rainbow"

# stdlib
require 'erb'

# modules
require_relative "instruct/env"
require_relative "instruct/expression"
require_relative "instruct/lm/variables"
require_relative "instruct/lm/erb_context"
require_relative "instruct/lm"
require_relative "instruct/version"

module Instruct
  class Error < StandardError; end

  class Todo < Error
    def message
      "not implemented yet"
    end
  end
end
