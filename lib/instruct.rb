# stdlib
require 'erb'
require 'ostruct'

# dependencies

# utils
require_relative "instruct/utils/middleware_chain"
require_relative "instruct/utils/attributed_string"
require_relative "instruct/utils/symbolize_keys"

# modules
require_relative "instruct/env"
require_relative "instruct/error"
require_relative "instruct/expression"
require_relative "instruct/lm/variables"
require_relative "instruct/lm/erb_context"
require_relative "instruct/lm"
require_relative "instruct/model"
require_relative "instruct/model/completion_response"
require_relative "instruct/model/completion_request"
require_relative "instruct/model/chat_completion_middleware"
require_relative "instruct/model/chomp_middleware"
require_relative "instruct/transcript"
require_relative "instruct/version"

# optional dependencies
begin
  require 'rainbow'
rescue LoadError
end

begin
  require "ruby/openai"
rescue LoadError
end

if defined? ::OpenAI
  require_relative "instruct/openai/completion_response"
  require_relative "instruct/openai/chat_completion_response"
else
end
