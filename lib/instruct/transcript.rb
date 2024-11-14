module Instruct
  # The transcript is an ordered record of prompts and language model responses.
  # When an expression is processed by an {Instruct::LM} instance a new entry is added to the transcript.
  #
  # When an expression for a completion request is processed by {Instruct::LM}
  # the transcript is the primary argument in the request.
  # The {Instruct::Model::CompletionRequest request} is then sent to a model (comprised of a {file:docs/prompt-completion-middleware.md middleware}) and
  # a completion model such as GPT-4o). The middleware pipeline transforms the
  # transcript for the completion model and then transforms the response from
  # the completion model before adding it to the transcript.
  class Transcript

    attr_reader :attr_string
    def initialize
      @attr_string = Instruct::AttributedString.new
    end

    def middleware_storage
      @middleware_storage ||= {}
    end

    # Adds an element to the transcript that was created by a prompt.
    #
    # @param calling_expression [Instruct::Expression] The expression created by the library caller that generated the transcript entry.
    # @param content [String] The content of the transcript entry.
    # @param mime [String] The mime type of the transcript entry (must be text/plain).
    # @param prompt_safe [Boolean] Whether the content came from a safe source (i.e. developer) or is unsafe and from a user or llm. Similar to html_safe.
    def add_prompt_element(calling_expression:, content:, mime:, prompt_safe:)
      raise ArgumentError, "Expected mime to be 'text/plain'." unless mime == 'text/plain'
      new_range = @attr_string.append_and_get_new_range(content)
      @attr_string.add_attributes(new_range, {
        calling_expression:,
        prompt_safe:,
        source: :prompt
      })
    end

    def hide_character_range(range, by:)
      @attr_string.add_arr_attributes(range, {
        hide: by
      })
    end

    def unhide_character_range(range, by:)
      @attr_string.add_arr_attributes(range, {
        unhide: by
      })
    end

    # Adds an element to the transcript that was created by a model response.
    def add_response_element(calling_expression:, content:, mime:, prompt_safe:, model_response:)
      raise ArgumentError, "Expected mime to be 'text/plain'." unless mime == :'text/attr-string'
      new_range = @attr_string.append_and_get_new_range(content)
      @attr_string.add_attributes(new_range, {
        calling_expression:,
        prompt_safe:,
        source: :llm,
      })
    end

    def ==(other)
      self.class == other.class && @attr_string == other.get_instance_variable(:@attr_string)
      binding.irb
    end

    def to_s(show_hidden: true)
      if show_hidden
        @attr_string.string
      else
        @attr_string.filtered_string do | attributes |
          next !attributes.has_key?(:hide) unless attributes.has_key?(:unhide)
          (attributes[:hide] - attributes[:unhide]).empty?
        end
      end
    end

    def dup
      Instruct::Transcript.new.send(:initialize_dup, @attr_string, @middleware_storage.dup || {})
    end

    def pretty_string
      change_based_on_attrs = [:source, :hide, :unhide, :prompt_safe]
      result = ""
      current_range = ""
      last_attrs = {}
      @attr_string.each_char do |char, attributes|
        attrs = attributes.slice(*change_based_on_attrs)
        if last_attrs != attrs
          current_range = rainbowize_string(current_range, last_attrs) unless current_range.empty?
          result += current_range
          current_range = ""
          last_attrs = attrs
        end
        current_range += char
      end
      result += rainbowize_string(current_range, last_attrs) unless current_range.empty?
    end

    private

    def rainbowize_string(string, attrs)
      result = Rainbow(string)
      result = result.bg(:green) if attrs[:source] == :llm
      if attrs[:prompt_safe] == false
        result = attrs[:source] == :llm ? result.color(:pink) : result.color(:red)
      end
      result = result.bg(:red) if (attrs[:hide] || []) - (attrs[:unhide] || []) != []
      result
    end

    def initialize_dup(attr_string, middleware_storage)
      @middleware_storage = {}
      middleware_storage.each do |key, value|
        @middleware_storage[key] = value.dup
      end
      @attr_string = attr_string.dup
      self
    end

  end
end
