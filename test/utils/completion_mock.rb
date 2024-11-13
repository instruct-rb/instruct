class CompletionMock
  class ModelMock
    def initialize
      @mock = Minitest::Mock.new
    end

    def method_missing(method_name, *args, &block)
      @mock.send(method_name, *args, &block)
    end
  end
  def initialize(middlewares: nil)
    super()
    middlewares ||= [Instruct::Model::ChompMiddleware]
    @mock = ModelMock.new
    middlewares << @mock
    @chain = Instruct::MiddlewareChain.new(middlewares: middlewares)
  end

  def verify
    @mock.verify
  end

  def execute(req)
    @chain.execute(req)
  end

  def call(req)
    @chain.execute(req)
  end

  def add_expected_completion(expected_prompt, response, **kwargs)
    @mock.expect(:call, response) do |req|
      text_transcript = req.transcript.to_s(show_hidden: false)
      if text_transcript != expected_prompt
        puts "Expected prompt: '#{expected_prompt}', but got: '#{text_transcript}'"
        false
      else
       true
      end
    end
  end
end
