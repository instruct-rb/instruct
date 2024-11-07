module Instruct
  class Error < StandardError; end

  class Todo < Error
    def message
      "not implemented yet"
    end
  end
end
