class Instruct::OpenAI
  class Middleware
    CLIENT_PARAMS = %i[api_type api_version access_token organization_id uri_base request_timeout extra_headers].freeze
    REQUEST_PARAMS = %i[store metadata frequency_penalty logit_bias logprobs top_logprobs max_completion_tokens n prediction presence_penalty response_format seed service_tier stop stream_options temperature top_p user].freeze

    def call(req, _next:)
      raise Instruct::Todo, "Non text modalities not supported yet, consider opening a pull request" if req.env[:modalities] && (req.env[:modalities] != [:text] || req.env[:modalities] != ["text"])
      raise Instruct::Todo, "Tools are not supported yet, consider opening a pull request" if req.env[:tools] || req.env[:tool_choice] || req.env[:parallel_tool_calls] || req.env[:function_call] || req.env[:functions]

      # Extract client options
      client_options = filter_env_keys(req, CLIENT_PARAMS)
      req.env[:openai_client_opts] = client_options
      #
      # Handle stop_chars conversion
      if req.env[:stop_chars].is_a?(String)
        req.env[:stop] = req.env[:stop_chars].split('')
      end

      # Extract request options
      request_options = filter_env_keys(req, REQUEST_PARAMS)
      req.env[:openai_args] = request_options

      # Handle deprecated arguments
      deprecated_args = [:max_tokens, :function_call, :functions]
      req.env[:openai_deprecated_args] = filter_env_keys(req, deprecated_args)


      req.add_prompt_transform do |attr_str|
        transform(attr_str)
      end

      _next.call(req)
    end

    def transform(prompt_obj)
      if prompt_obj.is_a?(Hash) && prompt_obj[:messages].is_a?(Array)
        prompt_obj[:messages].map! do |message|
          { role: message.keys.first, content: message.values.first.to_s }
        end
      end
      prompt_obj
    end

    private

    def filter_env_keys(req, keys)
      req.env.select { |k, _| keys.include?(k) }
    end
  end
end
