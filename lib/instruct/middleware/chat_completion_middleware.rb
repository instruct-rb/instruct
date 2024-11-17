module Instruct
  # Converts transcript plain text entries into role-based conversation entries
  # See {file:docs/prompt-completion-middleware.md#label-Chat+Completion+Middleware}
  class ChatCompletionMiddleware

    def initialize(roles: [:system, :user, :assistant])
      @roles = roles
    end

    def call(req, _next:)
      role_changes = []

      control_str = req.transcript.filter do | attrs |
        attrs[:safe] == true
      end

      # scan the control string for role changes, defined
      # as newlines followed by whitespace, then a role name,
      # then a colon, then an optional single space which is chomped.
      role_change_re = /(?:^|\n)\s*(\w+):\s?/
      control_str.scan(role_change_re) do |match|
        range_of_full_match = Regexp.last_match.offset(0)

        ranges = control_str.original_ranges_for(range_of_full_match[0]..range_of_full_match[1] - 1)
        start = control_str.original_position_at(ranges.first.first)
        finish = control_str.original_position_at(ranges.last.last)

        role = match[0].to_sym
        if @roles.include?(role)
          role_changes << { role: role, control_start: start, control_finish: finish }
        end
      end

      start_pos = 0
      role = @roles.first
      role_changes.each do |change|
        if change[:control_start] > start_pos
          req.transcript.add_attrs(start_pos...change[:control_start], role: role)
        end
        start_pos = change[:control_finish] + 1
        role = change[:role]
      end
      req.transcript.add_attrs(start_pos...req.transcript.length, role: role)

      req.add_prompt_transform do | attr_str |
        transform(attr_str)
      end

      if req.transcript.attrs_at(req.transcript.length - 1)[:role] != :assistant && @roles.include?(:assistant)
        req.transcript.safe_concat(Transcript.new("\nassistant: ", source: :chat_completion_middleware))
      end

      # need to work out pos of each entry in text transcript
      _next.call(req)
    end

    def transform(prompt_str)
      # TODO: once there is an attributed string presenter
      # we can replace this
      messages = []
      message_range = 0...0
      role = nil
      prompt_str.each_char.with_index do |char, idx|
        prompt_attrs = prompt_str.attrs_at(idx)
        if prompt_attrs[:role] != role
          messages << { role => prompt_str[message_range].remove_attrs(:role) } unless message_range.size.zero? || role.nil?
          role = prompt_attrs[:role]
          message_range = idx...idx
        end
        message_range = message_range.first..idx
      end
      messages << { role => prompt_str[message_range].remove_attrs(:role) } unless message_range.size.zero? || role.nil?
      { messages: messages }
    end



  end
end
