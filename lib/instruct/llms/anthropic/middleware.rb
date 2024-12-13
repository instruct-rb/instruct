class Instruct::Anthropic
  class Middleware
    include Instruct::Serializable
    set_instruct_class_id 201

    CLIENT_PARAMS = %i[access_token anthropic_version api_version extra_headers request_timeout uri_base beta].freeze
    # TODO: make request params settable at the model level, its silly to not set temperature in one place
    REQUEST_PARAMS = %i[metadata max_tokens temperature tools tool_choice top_k top_p stop_sequences system].freeze

    def call(req, _next:)
      raise Instruct::Todo, "Tools are not supported yet, consider opening a pull request" if req.env[:tools] || req.env[:tool_choice]

      # pull out the client options that were in the call and put them in anthropic_client_opts
      client_options = filter_env_keys(req, CLIENT_PARAMS)
      transform_beta_argument_into_extra_headers(client_options, req.env[:beta])

      req.env[:anthropic_client_opts] = client_options

      # pull out the message request params and put them in anthropic_messages_opts
      request_options = filter_env_keys(req, REQUEST_PARAMS)
      if request_options[:system].nil?
        # TODO: this will probably go back into the chat completion middleware and can be removed
        request_options[:system] = req.env[:system_from_prompt].to_s
      end
      normalize_stop_sequence_arguments(req, request_options)

      req.env[:anthropic_messages_opts] = request_options

      req.add_prompt_transform do | prompt_obj |
        transform(prompt_obj)
      end

      _next.call(req)
    end

    private

    def filter_env_keys(req, keys)
      req.env.select { |k, _| keys.include?(k) }
    end

    def normalize_stop_sequence_arguments(req, request_options)
      # Make the stop_chars and stop options consistent with openai
      if req.env[:stop_chars].is_a?(String)
        request_options[:stop_sequences] = req.env[:stop_chars].split('')
      end
      if req.env[:stop].is_a?(String)
        request_options[:stop_sequences] = [req.env[:stop]]
      elsif req.env[:stop].is_a?(Array)
        request_options[:stop_sequences] = req.env[:stop]
      end
    end

    def transform(prompt_obj)
      raise RuntimeError, "Expected hash with messages, probably missing chat completion middleware" unless prompt_obj.is_a?(Hash) && prompt_obj[:messages].is_a?(Array)
      remove_system_message(prompt_obj)
      convert_messages_to_anthropic_format(prompt_obj)
      prompt_obj
    end

    def remove_system_message(prompt_obj)
      prompt_obj[:messages].reject! { |message| message.keys.first == :system }
    end

    def convert_messages_to_anthropic_format(prompt_obj)
      prompt_obj[:messages].map! do |message|
        { role: message.keys.first, content: message.values.first.to_s }
      end
    end

    # This method takes the beta argument and transforms it into a header for the client
    def transform_beta_argument_into_extra_headers(client_options, beta)
      return unless beta
      client_options.delete(:beta)
      client_options[:extra_headers] ||= {}

      if client_options[:extra_headers]['anthropic-beta']
        raise ArgumentError, "Cannot set anthropic-beta header to #{beta} when it is already set to #{client_options[:extra_headers]['anthropic-beta']}."
      end

      if beta.is_a?(Array)
        client_options[:extra_headers]['anthropic-beta'] = beta.join(',')
      elsif beta.is_a?(String)
        client_options[:extra_headers] ||= {}
        client_options[:extra_headers]['anthropic-beta'] = beta.to_s
      else
        raise ArgumentError, "beta must be a string or an array of strings"
      end
    end
  end
end
