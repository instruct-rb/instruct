require 'test_helper'

class ArrAttributedStringTest < Minitest::Test
  def setup
    @string = "Hello, World!"
    @attr_string = Instruct::AttributedString.new(@string)
  end

  def test_arr_add_attributes_simple
    @attr_string.add_attributes(0..4, { user: 0 })
    0.upto(4) do |i|
      assert_equal({ user: 0 }, @attr_string.attributes_at(i))
    end
    @attr_string.add_arr_attributes(0..4, { user: 1 })
    0.upto(4) do |i|
      assert_equal({ user: [0, 1] }, @attr_string.attributes_at(i))
    end
    @attr_string.add_arr_attributes(0..4, { user: [2] })
    0.upto(4) do |i|
      assert_equal({ user: [0, 1, 2] }, @attr_string.attributes_at(i))
    end
    5.upto(12) do |i|
      assert_equal({}, @attr_string.attributes_at(i))
    end
  end


end
