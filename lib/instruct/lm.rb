module Instruct
  class LM
    include Instruct::LM::Variables
    attr_reader :transcript

    def initialize(completion_model: nil, transcript: nil, unprocessed_expressions: [], variables: {})
      initialize_variables(variables)
      @completion_model = completion_model
      @transcript = transcript.dup || Transcript.new
      unprocessed_expressions.each { |expression| process_expression(expression) }
    end

    def dup(**kwargs)
      instance_vars = {completion_model: @completion_model, transcript: @transcript, variables: dup_variables}
      Instruct::LM.new(**instance_vars.merge(kwargs))
    end

    def process_expression(expression, user_expression: nil)
      user_expression ||= expression
      if expression.is_a?(Instruct::Expression::PlainText)
        @transcript.add_prompt_element(
          calling_expression: user_expression,
          content: expression.text,
          mime: 'text/plain',
          prompt_safe: expression.prompt_safe?
        )
      elsif expression.is_a?(Instruct::Expression::LLMFuture)
        result = resolve_llm_future(expression)

        # TODO this should be a method on the expression
        capture_result_in_variable(result, name: expression.kwargs[:name], arr_name: expression.kwargs[:arr_name])

        @transcript.add_response_element(
          calling_expression: user_expression,
          content: result,
          mime: 'text/plain',
          prompt_safe: expression.prompt_safe?,
          model_response: Todo.new
        )
      elsif expression.is_a?(Instruct::Expression::ERBFuture)
        result = render_template(expression)
        @transcript.add_prompt_element(
          calling_expression: user_expression,
          content: result,
          mime: 'text/plain',
          prompt_safe: expression.prompt_safe?
        )
      else
        raise Todo
      end
    end

    def f(&block)
      Instruct::Expression::ERBFuture.new(block)
      # prompt_content = block_given? ? render_template(&block) : raise(ArgumentError, 'Block required')
      # Prompt.new(:text, prompt_content)
    end

    def gen(**kwargs)
      # TODO: refactor most of this into erb context, it'll make this way simpler
      called_within_erb_template = kwargs.delete(:_instruct_erb_context)
      return Instruct::Expression::LLMFuture.new(**kwargs) unless called_within_erb_template

      # if we arrive here, we are in the context of an ERBFuture expression
      # that is having its ERB template rendered as it's being processed
      #
      # partial output contains the plain text portion of the erb template
      # and
      partial_output, erb_future_expression = called_within_erb_template
      plain_text = Instruct::Expression::PlainText.new(partial_output, prompt_safe: erb_future_expression.should_mark_child_plain_text_as_prompt_safe?)
      process_expression(plain_text, user_expression: erb_future_expression)
      llm_future = Instruct::Expression::LLMFuture.new(**kwargs.merge(prompt_safe: erb_future_expression.should_mark_child_llm_future_as_prompt_safe?))
      process_expression(llm_future, user_expression: erb_future_expression)
      nil # we're adding directly to transcript so we don't put anything in _erbout
    end

    def +(other)
      other = Instruct::Expression::PlainText.new(other, prompt_safe: false) if other.is_a?(String)
      raise ArgumentError unless other.is_a? (Instruct::Expression::Expression)
      if other.is_a?(Instruct::Expression::Concat)
        return other.expressions.reduce(self, :+)
      end

      dup(unprocessed_expressions: [other])
    end

    def transcript_string
      return @transcript.to_s
    end

    def transcript_pretty_string
      raise Todo, "move this to transcript class"
      return transcript_string unless defined? Rainbow
      transcript.map do |entry|
        # case entry[:type]
        # when :llm
        #   Rainbow(entry[:text]).bg(:green)
        # when :text
        #   Rainbow(entry[:text])
        # else
        #   Rainbow(entry[:text]).underline
        # end
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
      req = Model::CompletionRequest.new(transcript, **expression.kwargs)
      response_text = @completion_model.execute(req)
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
