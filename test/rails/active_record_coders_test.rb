require_relative "rails_test_helper"


class RailsActiveJobObjectSerializerTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def test_can_dump_and_load_transcript
    transcript = Instruct::Transcript.new("Hello World") + gen
    obj = Instruct::Transcript.load(Instruct::Transcript.dump(transcript))
    assert_equal transcript, obj
    skip "needs documentation"
  end

end
