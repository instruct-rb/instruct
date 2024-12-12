module Instruct::OpenAI
  class Middleware
    CLIENT_PARAMS = %i[access_token anthropic_version api_version extra_headers request_timeout uri_base].freeze
    REQUEST_PARAMS = %i[store metadata frequency_penalty logit_bias logprobs top_logprobs max_completion_tokens n prediction presence_penalty response_format seed service_tier stop stream_options temperature top_p user].freeze
    def call(req, _next:)
      raise Instruct::Todo, "Non text modalities not supported yet, consider opening a pull request" if req.env[:modalities] && (req.env[:modalities] != [:text] || req.env[:modalities] != ["text"])
      raise Instruct::Todo, "Tools are not supported yet, consider opening a pull request" if req.env[:tools] || req.env[:tool_choice] || req.env[:parallel_tool_calls] || req.env[:function_call] || req.env[:functions]

      deprecated_args = [:max_tokens, :function_call, :functions]
      req.env[:openai_deprecated_args] = {}.tap do |a|
        deprecated_args.each do |arg|
          a[arg] = req.env[arg] if req.env[arg]
        end
      end

      if req.env[:stop_chars].is_a?(String)
        req.env[:stop] = req.env[:stop_chars].split('')
      end

      # TODO: make this more like anthropic
      args = [:store, :metadata, :frequency_penalty, :logit_bias, :logprobs, :top_logprobs, :max_completion_tokens]
      args += [:n, :prediction, :presence_penalty, :response_format, :seed, :service_tier]
      args += [:stop, :stream_options, :temperature, :top_p, :user]

      req.env[:openai_args] = {}.tap do |a|
        args.each do |arg|
          a[arg] = req.env[arg] if req.env[arg]
        end
      end

      req.add_prompt_transform do | attr_str |
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

  end
end
