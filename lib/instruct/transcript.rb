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

    attr_reader :elements
    def initialize(elements: [])
      @elements = elements
    end

    # Adds an element to the transcript that was created by a prompt.
    #
    # @param calling_expression [Instruct::Expression] The expression created by the library caller that generated the transcript entry.
    # @param content [String] The content of the transcript entry.
    # @param mime [String] The mime type of the transcript entry (must be text/plain).
    # @param prompt_safe [Boolean] Whether the content came from a safe source (i.e. developer) or is unsafe and from a user or llm. Similar to html_safe.
    def add_prompt_element(calling_expression:, content:, mime:, prompt_safe:)
      raise ArgumentError, "Expected mime to be 'text/plain'." unless mime == 'text/plain'
      @elements << OpenStruct.new( calling_expression:, source: :prompt, content: , mime:, prompt_safe:)
    end

    # Adds an element to the transcript that was created by a model response.
    def add_response_element(calling_expression:, content:, mime:, prompt_safe:, model_response:)
      raise ArgumentError, "Expected mime to be 'text/plain'." unless mime == 'text/plain'
      @elements << OpenStruct.new( calling_expression:, source: :model, content: , mime:, prompt_safe:, model_response:)
    end

    def dup
      Transcript.new(elements: @elements.map(&:dup))
    end

    # Maps the transcript structs to a new array of duplicated structs that can be modified.
    def map(prompt_safe: nil, &block)
      Transcript.new(elements: @elements.map(&:dup).map(&block))
    end

    def ==(other)
      self.class == other.class && @elements == other.elements
    end

    def to_s
      @elements.map do |entry|
        if entry.mime == 'text/plain'
          entry.content
        else
          raise Todo
        end
      end.join("")
    end
  end
end
