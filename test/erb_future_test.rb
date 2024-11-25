require_relative 'test_helper'

class ERBFutureTest < Minitest::Test
  using Instruct::Refinements
  # def setup
  #   @mock = MockCompletionModel.new
  #   @lm = Instruct::LM.new(completion_model: @mock)
  # end

  # def process(erb_future)
  #   result = TranscriptString.new
  #   erb_future.process(lm: @lm) do |t|
  #     result << t
  #   end
  #   result
  # end

  # def test_safe_is_correctly_captured
  #   safe_var = 'safe'
  #   result = process erb{"this is #{safe_var}"}
  #   0.upto(result.length-1) do |i|
  #     assert result.attrs_at(i)[:safe]
  #   end
  #   assert_equal "this is safe", result.to_s
  # end

  # def test_unsafe_is_correctly_captured
  #   unsafe_var = 'unsafe'
  #   _ = unsafe_var
  #   result = process erb{'this is <%= unsafe_var %>.'}
  #   assert_equal "this is unsafe.", result.to_s
  #   0.upto(7) do |i|
  #     assert result.attrs_at(i)[:safe]
  #   end
  #   assert result.attrs_at(result.length - 1)[:safe] == true
  # end

  # def test_raw_is_marked_as_safe
  #   unsafe_var = 'unsafe'
  #   _ = unsafe_var
  #   result = process erb{'this is <%= raw unsafe_var %>.'}
  #   assert_equal "this is unsafe.", result.to_s
  #   0.upto(result.length-1) do |i|
  #     assert result.attrs_at(i)[:safe]
  #   end
  # end

  # def test_single_llmgen_works_in_erb
  #   @mock.expect_completion("this is ", "unsafe")
  #   erb_future = erb{'this is <%= gen %>.'}
  #   result = process erb_future
  #   assert_equal "this is unsafe.", result.to_s
  #   0.upto(7) do |i|
  #     assert result.attrs_at(i)[:safe]
  #   end
  #   assert result.attrs_at(result.length - 1)[:safe] == true
  #   @mock.verify
  # end

  # def test_capture_works_and_is_unsafe_by_default
  #   @mock.expect_completion("capture this ", "unsafe")
  #   @mock.expect_completion("capture this unsafe", "unsafe")
  #   erb_future = erb{'capture this <%= gen(name: :x) %> in x and use it: <%= captured(:x) %>'}
  #   result = process erb_future
  #   assert_equal "capture this unsafe in x and use it: unsafe", result.to_s
  #   # 'capture this' is safe
  #   0.upto(12) do |i|
  #     assert result.attrs_at(i)[:safe]
  #   end
  #   # 'unsafe' is unsafe
  #   13.upto(18) do |i|
  #     assert_nil result.attrs_at(i)[:safe]
  #   end
  #   # ' in x and use it: ' is safe
  #   19.upto(36) do |i|
  #     assert result.attrs_at(i)[:safe]
  #   end
  #   # 'unsafe' is unsafe
  #   37.upto(42) do |i|
  #     assert_nil result.attrs_at(i)[:safe]
  #   end

  # end

end
