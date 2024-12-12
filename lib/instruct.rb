# stdlib
require 'erb'
require 'ostruct'

# dependencies
require 'attributed-string'
# require 'async/http/faraday'



# utils
require_relative "instruct/utils/middleware_chain"
require_relative "instruct/utils/symbolize_keys"
require_relative "instruct/utils/variables"

# modules

require_relative "instruct/compile_erb"
require_relative "instruct/env"
require_relative "instruct/error"
require_relative "instruct/model"
require_relative "instruct/gen/completion_response"
require_relative "instruct/gen/completion_request"
require_relative "instruct/gen/gen"
require_relative "instruct/middleware/chat_completion_middleware"
require_relative "instruct/middleware/chomp_middleware"
require_relative "instruct/transcript"
require_relative "instruct/version"

require_relative "instruct/helpers/erb_helper"
require_relative "instruct/helpers/gen_helper"
require_relative "instruct/helpers/model_helper"
require_relative "instruct/helpers/refinements"
require_relative "instruct/helpers/helpers"

# optional dependencies
begin
  require 'rainbow'
rescue LoadError
end

# if the caller is using ruby-openai gem
begin
  require "ruby/openai"
rescue LoadError
end

if defined? ::OpenAI
  require_relative "instruct/llms/openai/middleware"
  require_relative "instruct/llms/openai/completion_model"
  require_relative "instruct/llms/openai/completion_response"
  require_relative "instruct/llms/openai/chat_completion_response"
  Instruct.openai_loaded = true
else
end

# if the caller is using ruby/anthropic gem
begin require "anthropic"
rescue LoadError
end

if defined? ::Anthropic
  require_relative "instruct/llms/anthropic/middleware"
  require_relative "instruct/llms/anthropic/completion_model"
  require_relative "instruct/llms/anthropic/messages_completion_response"
  Instruct.anthropic_loaded = true
else
end
