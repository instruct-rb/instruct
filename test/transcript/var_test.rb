  require_relative '../test_helper'

  class VarTest < Minitest::Test
    # def test_a_list_of_2_animals
    #   mock = MockCompletionModel.new(middlewares: [Instruct::ChompMiddleware])
    #   mock.expect_completion("Please think of 2 different animals on separate lines.\nAnimal 1:", "Zebra", stop: "\n")
    #   mock.expect_completion("Please think of 2 different animals on separate lines.\nAnimal 1: Zebra\nAnimal 2:", "Lion", stop: "\n")
    #   lm = Instruct::LM.new(completion_model: mock)
    #   lm += 'Please think of 2 different animals on separate lines.'
    #   2.times do |i|
    #     # lm += lm.f{ "\nAnimal #{i+1}: <%= gen(stop: '\n') %>" }
    #     lm += "\nAnimal #{i+1}: "
    #     lm += lm.gen(name: :animal, arr_name: :animals, stop: "\n")
    #   end
    #   mock.verify
    #   assert_equal "Please think of 2 different animals on separate lines.\nAnimal 1: Zebra\nAnimal 2: Lion", lm.transcript_string
    #   assert_equal ["Zebra", "Lion"], lm[:animals]
    #   assert_equal "Lion", lm[:animal]
    # end
  end
