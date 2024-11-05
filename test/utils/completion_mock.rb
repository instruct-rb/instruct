class CompletionMock < Minitest::Mock
  def initialize
    super
  end

  def add_expected_completion(expected_prompt, response, **kwargs)
    expect(:completion, response, [expected_prompt], **kwargs)
  end
end
