module Instruct
  class LM
    # include Instruct::LM::Variables
    attr_reader :transcript

    def initialize(completion_model: nil, transcript: [], unprocessed_expressions: [])
      @completion_model = completion_model
      @transcript = transcript.dup
      unprocessed_expressions.each { |expression| process_expression(expression) }
    end

    def dup(**kwargs)
      instance_vars = {completion_model: @completion_model, transcript: @transcript}
      Instruct::LM.new(**instance_vars.merge(kwargs))
    end

    def process_expression(expression)
      if expression.is_a?(Instruct::Expression::PlainText)
        add_to_transcript(expression, :text, expression.text)
      elsif expression.is_a?(Instruct::Expression::LLMFuture)
        result = resolve_llm_future(expression)
        add_to_transcript(expression, :llm, result)
      elsif expression.is_a?(Instruct::Expression::ERBFuture)
        result = render_template(expression)
        add_to_transcript(expression, :text, result)
      else
        raise Todo
      end
    end

    def add_to_transcript(expression, type, text)
      @transcript << {expression: expression, type: type, text: text}
    end

    def f(&block)
      Instruct::Expression::ERBFuture.new(block)
      # prompt_content = block_given? ? render_template(&block) : raise(ArgumentError, 'Block required')
      # Prompt.new(:text, prompt_content)
    end

    def gen(**kwargs)
      instruct_erb_context = kwargs.delete(:_instruct_erb_context)
      new_expression = Instruct::Expression::LLMFuture.new(**kwargs)
      return new_expression unless instruct_erb_context

      partial_output, expression = instruct_erb_context
      add_to_transcript(expression, :text, partial_output)
      result = resolve_llm_future(new_expression)
      add_to_transcript(expression, :llm, result)
      nil # we're adding directly to transcript so we don't wat to put anything in _erbout
    end

    def +(other)
      other = Instruct::Expression::PlainText.new(other) if other.is_a?(String)
      raise ArgumentError unless other.is_a? (Instruct::Expression::Expression)
      if other.is_a?(Instruct::Expression::Concat)
        return other.expressions.reduce(self, :+)
      end

      dup(unprocessed_expressions: [other])
    end

    def transcript_string
      transcript.map { |entry| entry[:text] }.join
    end

    def transcript_pretty_string
      return transcript_string unless defined? Rainbow
      transcript.map do |entry|
        case entry[:type]
        when :llm
          Rainbow(entry[:text]).bg(:green)
        when :text
          Rainbow(entry[:text])
        else
          Rainbow(entry[:text]).underline
        end
      end
      .join("")
    end

    def render_template(expression)
      block = expression.template_block
      template_str = block.call

      # Create a custom context for the ERB template
      erb_context = Instruct::LM::ERBContext.new(self, block.binding, expression)

      # Create a new ERB template without specifying eoutvar
      erb_template = ERB.new(template_str, trim_mode: '-', eoutvar: '@_erbout')

      # Render the template within the context
      output = erb_template.result(erb_context.instance_eval { binding })

      output
    end


    private

    def resolve_llm_future(expression)
      whitespace = ''
      prompt_text = transcript_string.gsub(/( +)$/) do |match|
        whitespace = match
        ''
      end
      response_text = @completion_model.completion(prompt_text, **expression.kwargs)
      response_text = response_text[whitespace.length...] if response_text.start_with?(whitespace)
      response_text
    end


    Prompt = Struct.new(:role, :content) do
      def to_s
        return content if role == :text
        "#{role}: #{content}"
      end
    end
  end
end
