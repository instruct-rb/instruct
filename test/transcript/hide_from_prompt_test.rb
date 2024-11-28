require_relative "../test_helper"

class TranscriptHideFromPromptTest < MiddlewareTest
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new
    self._instruct_default_model = @mock
  end

  def test_transcript_marked_for_deletion_not_in_prompt
    transcript = Instruct::Transcript.new("a-d")
    transcript.hide_range_from_prompt(1..2, by: "test")
    assert_equal "a", transcript.prompt_object
    transcript.unhide_range_from_prompt(1..2, by: "test")
    assert_equal "a-d", transcript.prompt_object
  end
end
