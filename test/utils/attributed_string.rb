require 'test_helper'

class TestAttributedString < Minitest::Test
  def setup
    @string = "Hello, World!"
    @attr_string = Instruct::AttributedString.new(@string)
  end

  def test_add_attributes_simple
    @attr_string.add_attributes(0..4, { bold: true })
    0.upto(4) do |i|
      assert_equal({ bold: true }, @attr_string.attributes_at(i))
    end
    5.upto(12) do |i|
      assert_equal({}, @attr_string.attributes_at(i))
    end
  end

  def test_add_attributes_excluded_end_range
    @attr_string.add_attributes(0...5, { bold: true })
    0.upto(4) do |i|
      assert_equal({ bold: true }, @attr_string.attributes_at(i))
    end
    5.upto(12) do |i|
      assert_equal({}, @attr_string.attributes_at(i))
    end
  end

  def test_add_attributes_overlap_overwrite
    @attr_string.add_attributes(0..4, { font_size: 9 })
    @attr_string.add_attributes(2..8, { font_size: 12 })
    0.upto(1) do |i|
      assert_equal({ font_size: 9 }, @attr_string.attributes_at(i))
    end
    2.upto(8) do |i|
      assert_equal({ font_size: 12 }, @attr_string.attributes_at(i))
    end
    9.upto(12) do |i|
      assert_equal({}, @attr_string.attributes_at(i))
    end
  end

  def test_simple_remove_attribute
    @attr_string.add_attributes(0..4, { bold: true })
    @attr_string.remove_attributes(0..4, :bold)
    0.upto(12) do |i|
      assert_equal({}, @attr_string.attributes_at(i))
    end
  end

  def test_remove_attribute_leaves_others
    @attr_string.add_attributes(0..4, { bold: true, font_size: 12 })
    @attr_string.remove_attributes(0..4, :bold)
    0.upto(4) do |i|
      assert_equal({ font_size: 12 }, @attr_string.attributes_at(i))
    end
    5.upto(12) do |i|
      assert_equal({}, @attr_string.attributes_at(i))
    end
  end

  def test_remove_attribute_splits_range
    @attr_string.add_attributes(0..4, { bold: true, font_size: 12 })
    @attr_string.remove_attributes(2..3, :bold)
    0.upto(1) do |i|
      assert_equal({ bold: true, font_size: 12 }, @attr_string.attributes_at(i))
    end
    2.upto(3) do |i|
      assert_equal({ font_size: 12 }, @attr_string.attributes_at(i))
    end
    4.upto(4) do |i|
      assert_equal({ bold: true, font_size: 12 }, @attr_string.attributes_at(i))
    end
    5.upto(12) do |i|
      assert_equal({}, @attr_string.attributes_at(i))
    end

    def test_add_attributes_overlap_different
      @attr_string.add_attributes(0..4, { bold: true })
      @attr_string.add_attributes(3..7, { italic: true })
      0.upto(2) do |i|
        assert_equal({ bold: true }, @attr_string.attributes_at(i))
      end
      3.upto(4) do |i|
        assert_equal({ bold: true, italic: true })
      end
      5.upto(7) do |i|
        assert_equal({ italic: true }, @attr_string.attributes_at(i))
      end
      8.upto(12) do |i|
        assert_equal({}, @attr_string.attributes_at(i))
      end
    end

    def test_dup
      @attr_string.add_attributes(0..4, { bold: true })
      dup = @attr_string.dup
      0.upto(4) do |i|
        assert_equal({ font_size: 12 }, dup.attributes_at(i))
      end
      5.upto(12) do |i|
        assert_equal({}, dup.attributes_at(i))
      end
    end


  end
end
