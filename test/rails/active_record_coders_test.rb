require_relative "rails_test_helper"


class RailsActiveJobObjectSerializerTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def test_can_dump_and_load_prompt
    prompt = Instruct::Prompt.new("Hello World") + gen
    obj = Instruct::Prompt.load(Instruct::Prompt.dump(prompt))
    assert_equal prompt, obj
    skip "needs documentation"
  end

end
