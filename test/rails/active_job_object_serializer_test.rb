require_relative "rails_test_helper"


class RailsActiveJobObjectSerializerTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new
    self.instruct_default_model = @mock
  end
  def test_serializer_works
    transcript = Instruct::Transcript.new("system: a\nuser: b\nassistant: c".prompt_safe) + gen
    data = ActiveJob::Serializers.serialize( transcript)
    obj = ActiveJob::Serializers.deserialize(data)
    assert_equal transcript, obj
  end

end
