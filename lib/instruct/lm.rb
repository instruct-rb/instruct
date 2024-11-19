module Instruct
  class LM
    include Instruct::LM::Variables
    attr_reader :transcript

    def initialize(completion_model: nil, transcript: nil, unprocessed_expressions: [], variables: {})
      initialize_variables(variables)
      @completion_model = completion_model
      @transcript = transcript.dup || TranscriptString.new
      @streaming_transcript = nil
      unprocessed_expressions.each { |expression| process_expression(expression) }
    end

    def dup(**kwargs)
      instance_vars = {completion_model: @completion_model, transcript: @transcript, variables: dup_variables}
      Instruct::LM.new(**instance_vars.merge(kwargs))
    end

    def process_expression(expression)
      # maybe add finalized and an unfinalized transcript string if we need the streamed result in lm
      expression.process(lm: self) do | result |
        result.add_attrs(expression: expression)
        @transcript.concat(result)
      end
    end

    def f(&block)
      Instruct::Expression::ERBFuture.new(template: block.call, binding: block.binding)
    end


    def gen(transcript: self.transcript, deferred: true, **kwargs, &block)
      return Instruct::Expression::LLMFuture.new(**kwargs) if deferred

      _gen(transcript:, **kwargs, &block)
    end

    def +(other)
      other = Instruct::Expression::PlainText.new(other, safe: false) if other.is_a?(String)
      raise ArgumentError unless other.is_a? (Instruct::Expression::Expression)
      if other.is_a?(Instruct::Expression::Concat)
        return other.expressions.reduce(self, :+)
      end

      dup(unprocessed_expressions: [other])
    end

    def transcript_string(show_hidden: true)
      return @transcript.to_s
    end

    private

    def _gen(transcript:, **kwargs, &block)
      model = kwargs.delete(:model) || @completion_model
      request = Model::CompletionRequest.new(transcript, **kwargs)
      @streaming_transcript = transcript.dup
      request.add_stream_handler do |response|
        @streaming_transcript.concat(response)
        yield(@streaming_transcript) if block_given?
      end
      response = request.execute(model)
      attr_string = response.attributed_string
      capture_result_in_variable(attr_string, **kwargs)
      attr_string
    end


    Prompt = Struct.new(:role, :content) do
      def to_s
        return content if role == :text
        "#{role}: #{content}"
      end
    end
  end
end
