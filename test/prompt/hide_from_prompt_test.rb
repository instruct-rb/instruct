require_relative "../test_helper"

class TranscriptHideFromPromptTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new
    self.instruct_default_model = @mock
  end

  def test_prompt_marked_for_deletion_not_in_prompt
    prompt = Instruct::Prompt.new("a-d")
    prompt.hide_range_from_prompt(1..2, by: "test")
    assert_equal "a", prompt.prompt_object
    prompt.unhide_range_from_prompt(1..2, by: "test")
    assert_equal "a-d", prompt.prompt_object
  end
end
