module Instruct::Model
  # Converts transcript plain text entries into role-based conversation entries
  # See {file:docs/prompt-completion-middleware.md#label-Chat+Completion+Middleware}
  class ChatCompletionMiddleware
    def initialize(roles: [:system, :user, :assistant])
    end

    def call(req, _next:)
      @pos = 0
      @current_role = nil

      # need to work out pos of each entry in text transcript
      _next.call(req)
    end

    def find_first_text
      req.transcript.elements[@pos]
    end

    def entry_peek(n)
      req.transcript.elements[@pos + n]
    end

    def entry_pop(n)
      req.transcript.elements[@pos + n]
    end




  end
end
