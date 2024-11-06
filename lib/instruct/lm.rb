module Instruct
  class LM
    include Instruct::LM::Variables
    attr_reader :transcript

    def initialize(completion_model: nil, transcript: [], unprocessed_expressions: [], variables: {})
      initialize_variables(variables)
      @completion_model = completion_model
      @transcript = transcript.dup
      unprocessed_expressions.each { |expression| process_expression(expression) }
    end

    def dup(**kwargs)
      instance_vars = {completion_model: @completion_model, transcript: @transcript, variables: dup_variables}
      Instruct::LM.new(**instance_vars.merge(kwargs))
    end

    def process_expression(expression, user_expression: nil)
      user_expression ||= expression
      if expression.is_a?(Instruct::Expression::PlainText)
        add_to_transcript(user_expression, :text, expression.text)
      elsif expression.is_a?(Instruct::Expression::LLMFuture)
        result = resolve_llm_future(expression)
        capture_result_in_variable(result, name: expression.kwargs[:name], arr_name: expression.kwargs[:arr_name])
        add_to_transcript(user_expression, :llm, result)
      elsif expression.is_a?(Instruct::Expression::ERBFuture)
        result = render_template(expression)
        add_to_transcript(user_expression, :text, result)
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
      called_within_erb_template = kwargs.delete(:_instruct_erb_context)
      new_expression = Instruct::Expression::LLMFuture.new(**kwargs)
      return new_expression unless called_within_erb_template

      # if we arrive here, we are in the context of an ERBFuture expression
      # that is having its ERB template rendered
      # partial output contains the plain text portion of the erb template
      # between gen calls within the template
      partial_output, expression = called_within_erb_template
      plain_text = Instruct::Expression::PlainText.new(partial_output)
      process_expression(plain_text, user_expression: expression)
      process_expression(new_expression, user_expression: expression)
      nil # we're adding directly to transcript so we don't put anything in _erbout
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
