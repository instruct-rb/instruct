require_relative "test_helper"

class FilterAttributedStringTest < Minitest::Test
  def setup
    @string = "Hello, World!"
    @attr_string = Instruct::AttributedString.new(@string)
  end

  def test_filtered_string_with_specific_attribute
    # Add bold attribute to "Hello"
    @attr_string.add_attributes(0..4, { bold: true })
    # Filter to include only characters with bold: true
    result = @attr_string.filtered_string { |attributes| attributes[:bold] == true }

    # Check that result is a FilteredString
    assert_instance_of Instruct::AttributedString::FilteredString, result
    # Check that the string content is "Hello"
    assert_equal("Hello", result)
    # Check that original positions are correct
    expected_positions = [0, 1, 2, 3, 4]
    expected_positions.each_with_index do |original_pos, idx|
      assert_equal(original_pos, result.original_position_at(idx))
    end
  end

  def test_filtered_string_with_multiple_attributes
    # Add attributes to different parts
    @attr_string.add_attributes(0..4, { bold: true })
    @attr_string.add_attributes(7..11, { italic: true })
    # Filter to include characters that are either bold or italic
    result = @attr_string.filtered_string do |attributes|
      attributes[:bold] == true || attributes[:italic] == true
    end

    assert_equal("HelloWorld", result)
    expected_positions = [0, 1, 2, 3, 4, 7, 8, 9, 10, 11]
    expected_positions.each_with_index do |original_pos, idx|
      assert_equal(original_pos, result.original_position_at(idx))
    end
  end

  def test_filtered_string_always_true_block
    # No attributes added
    result = @attr_string.filtered_string { |attributes| true }
    assert_equal(@string, result)
    # Check positions
    (0...result.length).each do |idx|
      assert_equal(idx, result.original_position_at(idx))
    end
  end

  def test_filtered_string_always_false_block
    # No attributes added
    result = @attr_string.filtered_string { |attributes| false }
    assert_equal("", result)
    assert_raises(IndexError) { result.original_position_at(0) }
  end

  def test_filtered_string_with_overlapping_attributes
    # Add bold to "Hello"
    @attr_string.add_attributes(0..4, { bold: true })
    # Add italic to "lo, W"
    @attr_string.add_attributes(3..7, { italic: true })
    # Filter to include characters with both bold and italic
    result = @attr_string.filtered_string do |attributes|
      attributes[:bold] == true && attributes[:italic] == true
    end

    assert_equal("lo", result)
    expected_positions = [3, 4]
    expected_positions.each_with_index do |original_pos, idx|
      assert_equal(original_pos, result.original_position_at(idx))
    end
  end

  def test_filtered_string_no_attributes
    # No attributes added
    result = @attr_string.filtered_string { |attributes| attributes[:bold] == true }
    assert_equal("", result)
  end

  def test_filtered_string_partial_match
    # Add bold attribute to "Hello"
    @attr_string.add_attributes(0..4, { bold: true, color: 'red' })
    # Filter to include characters with color: 'red'
    result = @attr_string.filtered_string { |attributes| attributes[:color] == 'red' }
    assert_equal("Hello", result)
    expected_positions = [0, 1, 2, 3, 4]
    expected_positions.each_with_index do |original_pos, idx|
      assert_equal(original_pos, result.original_position_at(idx))
    end
  end

  def test_filtered_string_with_non_boolean_attributes
    # Add color attribute to "World"
    @attr_string.add_attributes(7..11, { color: 'blue' })
    # Filter to include characters with color 'blue'
    result = @attr_string.filtered_string { |attributes| attributes[:color] == 'blue' }
    assert_equal("World", result)
    expected_positions = [7, 8, 9, 10, 11]
    expected_positions.each_with_index do |original_pos, idx|
      assert_equal(original_pos, result.original_position_at(idx))
    end
  end

  def test_filtered_string_combined_attributes
    # Add attributes to "Hello"
    @attr_string.add_attributes(0..4, { bold: true, color: 'red' })
    # Add attributes to "World"
    @attr_string.add_attributes(7..11, { bold: true, color: 'blue' })
    # Filter to include bold characters
    result = @attr_string.filtered_string { |attributes| attributes[:bold] == true }
    assert_equal("HelloWorld", result)
    expected_positions = [0, 1, 2, 3, 4, 7, 8, 9, 10, 11]
    expected_positions.each_with_index do |original_pos, idx|
      assert_equal(original_pos, result.original_position_at(idx))
    end
  end

  def test_filtered_string_no_matching_attributes
    # Add bold to "Hello"
    @attr_string.add_attributes(0..4, { bold: true })
    # Filter to include characters with italic attribute
    result = @attr_string.filtered_string { |attributes| attributes[:italic] == true }
    assert_equal("", result)
  end

  def test_original_position_out_of_bounds
    # Add bold to "Hello"
    @attr_string.add_attributes(0..4, { bold: true })
    # Filter to include bold characters
    result = @attr_string.filtered_string { |attributes| attributes[:bold] == true }
    # Attempt to access an out-of-bounds position
    assert_raises(IndexError) { result.original_position_at(5) }
  end


end
