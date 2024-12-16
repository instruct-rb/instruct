require_relative "../test_helper"

class TranscriptSerializeTest < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new
    self.instruct_default_model = @mock
  end

  def dump_and_load(obj)
    data = Instruct::Serializer.dump(obj)
    Instruct::Serializer.load(data)
  end

  def test_transcript_serializes
    obj = Instruct::Transcript.new("hello", test: "world")
    loaded = dump_and_load(obj)
    assert_equal obj, loaded
  end

  def test_transcript_with_result_serializes
    @mock.expect_completion(nil, ["world"])
    obj = Instruct::Transcript.new << "hello " + gen().capture(:x, list: :y)
    loaded = dump_and_load(obj)
    assert_equal obj.captured(:x).to_s, "world"
    assert_equal obj.captured(:y).first.to_s, "world"
    assert_equal obj, loaded
    assert_equal loaded.captured(:x).to_s, "world"
    assert_equal loaded.captured(:y).first.to_s, "world"
  end

  def test_transcript_with_gen_serializes
    obj = Instruct::Transcript.new + "hello " + gen()
    loaded = dump_and_load(obj)
    assert_equal obj, loaded
  end

end
