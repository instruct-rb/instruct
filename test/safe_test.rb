require_relative 'test_helper'

class Test < Minitest::Test
  include Instruct::Helpers
  using Instruct::Refinements

  def setup
    @mock = MockCompletionModel.new
    self._instruct_default_model = @mock
  end

  def test_transcripts_are_unsafe_by_default
    prompt = "The capital of France is " + gen()
    expected = AttributedString.new(prompt, safe: false)
    assert_safe_match expected, prompt
  end

  def test_erb_is_safe_including_interpolated_values
    prompt = erb{"this is #{"safe"}"}
    assert_safe_match AttributedString.new("this is safe", safe: true), prompt
  end

  def test_inside_erb_tags_are_unsafe
    prompt = erb{'.<%= "this is unsafe" %>.'}
    period = AttributedString.new(".", safe: true)
    expected = period + AttributedString.new("this is unsafe", safe: false) + period
    assert_safe_match expected, prompt
  end

  def test_erb_with_raw_is_safe
    prompt = erb{'.<%= raw "this is safe" %>.'}
    expected = AttributedString.new(".this is safe.", safe: true)
    assert_safe_match expected, prompt
  end

  def test_prompt_safe_helper_is_safe
    prompt = "abc".prompt_safe + gen()
    expected = Instruct::Transcript.new("abc", safe: true) + gen()
    assert_safe_match expected, prompt
  end


end
