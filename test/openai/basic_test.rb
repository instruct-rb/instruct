require "test_helper"
require "ruby/openai"

# These tests could be flakey as they are based on llm responses
class OpenAIBasicTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::OpenAI::VERSION
  end
  def self.poem
    "poem"
  end
  def test_it_works
    model = Instruct::OpenAICompletionModel.new()
    lm = Instruct::LM.new(completion_model: model)
    classic = lm.safe("classic")
    goes =  "goes"
    lm += lm.f{<<~ERB
    The <%= classic %> <%= OpenAIBasicTest.poem %> <%= goes %>:
    Roses are red, violets are <%= gen(stop: [' ',"\n","\r",","]) %>, the honey is sweet, and so are <%= gen(stop: ["\n","\r"," ","."]) %>
    ERB
    .strip }
    assert_equal "The classic poem goes:\nRoses are red, violets are blue, the honey is sweet, and so are you", lm.transcript_string
    puts lm.transcript.pretty_string

  end
end
