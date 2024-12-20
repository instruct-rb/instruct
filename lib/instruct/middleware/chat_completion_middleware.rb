module Instruct
  # Converts prompt plain text entries into role-based conversation entries
  # See {file:docs/prompt-completion-middleware.md#label-Chat+Completion+Middleware}
  class ChatCompletionMiddleware
    include Instruct::Serializable
    set_instruct_class_id 4

    def initialize(roles: [:system, :user, :assistant])
      @roles = roles
    end

    def call(req, _next:)
      role_changes = []

      control_str = req.prompt.filter do | attrs |
        attrs[:safe] == true
      end

      # scan the control string for role changes, defined
      # as newlines followed by whitespace, then a role name,
      # then a colon, then an optional single space which is chomped.
      role_change_re = /(?:^|\n)\s*(\w+):\s?/
      control_str.scan(role_change_re) do |match|
        range_of_full_match = Regexp.last_match.offset(0)

        ranges = control_str.original_ranges_for(range_of_full_match[0]..range_of_full_match[1] - 1)
        start = ranges.first.first
        finish = ranges.last.last


        role = match[0].to_sym
        if @roles.include?(role)
          role_changes << { role: role, control_start: start, control_finish: finish }
        end
      end

      start_pos = 0
      role = @roles.first
      # TODO: we want to make it so that if no role changes are defined we fallback to the
      # default user role, and use the system: to define the system arg.
      role_changes.each do |change|
        if change[:control_start] > start_pos
          if role == :system
            req.env[:system_from_prompt] = req.prompt[start_pos...change[:control_start]]
          end
          req.prompt.add_attrs(start_pos...change[:control_start], role: role)
        end
        start_pos = change[:control_finish] + 1
        role = change[:role]
      end
      if role == :system
        req.env[:system_from_prompt] = req.prompt[start_pos...req.prompt.length]
      end
      req.prompt.add_attrs(start_pos...req.prompt.length, role: role)

      req.add_prompt_transform do | attr_str |
        transform(attr_str)
      end

      if req.prompt.attrs_at(req.prompt.length - 1)[:role] != :assistant && @roles.include?(:assistant)
        req.prompt.safe_concat(Prompt.new("\nassistant: ", source: :chat_completion_middleware))
      end

      # need to work out pos of each entry in text prompt
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
