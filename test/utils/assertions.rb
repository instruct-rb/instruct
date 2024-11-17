module Assertions
  def assert_safe_match(expected, actual)
    expected = AttributedString.new(expected) if expected.is_a?(String)
    actual = AttributedString.new(actual) if actual.is_a?(String)
    assert_equal expected.to_s, actual.to_s, "Expected #{expected.inspect}, got #{actual.inspect}"

    prefix = ""
    expected.chars.each_with_index do |char, index|
      expected_attr = expected.attrs_at(index)[:safe] || false
      actual_attr = actual.attrs_at(index)[:safe] || false
      assert_equal expected_attr, actual_attr, "Expected safe attribute at #{prefix}<issue>#{char}</issue> (index: #{index}) of \"#{actual.inspect}\" to match."
      prefix.concat(char)
    end
  end
end
