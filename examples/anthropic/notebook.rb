require "anthropic"
require "instruct"
require "attributed-string"

include Instruct::Helpers

# iruby notebook doesn't work with refinements
# Instead we use monkey patches
require_relative "../../lib/instruct/helpers/monkeypatches"

Instruct.suppress_warnings = true

class AttributedString
  def escape_html(html)
    CGI::escapeHTML(html).gsub("\n", "<br>").gsub("$", "\\$")
  end
end

class Instruct::Prompt
  def to_html; return "<span style='color: #333;'>#{escape_html(to_s(gen: :emoji))}</span>"; end
end
class Instruct::Prompt::Completion
  def to_html; return "<span style='color: #333; background: #0f0;'>#{escape_html(to_s)}</span>"; end
end
class Instruct::Gen
  alias_method :old_call, :call
  def call(*args, **kwargs, &streaming_block)
    # IRuby.display(IRuby.html("<span style='color: #333;'>#{escape_html(prompt.to_s(gen: :nochange))}</span>"))
    response = old_call(*args, **kwargs, &streaming_block)
    # IRuby.display(IRuby.html("<span style='color: #333;'>#{escape_html(response.to_s)}</span>"))
    response
  end
end
