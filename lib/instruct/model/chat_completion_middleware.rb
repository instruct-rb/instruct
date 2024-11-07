module Instruct::Model
  # Converts transcript entries from {}
  class ChatCompletionMiddleware
    def initialize
      @parser = RoleParser.new(roles: [:system, :user, :assistant])
    end

    def complete(req, next_completer:)
      next_completer.complete(req)
    end

    def escape(input, next_escaper:)
    end
  end
end
