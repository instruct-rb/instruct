module Instruct::OpenAI
  class ArgsMiddleware
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

      args = [:store, :metadata, :frequency_penalty, :logit_bias, :logprobs, :top_logprobs, :max_completion_tokens]
      args += [:n, :prediction, :presence_penalty, :response_format, :seed, :service_tier]
      args += [:stop, :stream_options, :temperature, :top_p, :user]

      req.env[:openai_args] = {}.tap do |a|
        args.each do |arg|
          a[arg] = req.env[arg] if req.env[arg]
        end
      end

      _next.call(req)


    end

  end
end
