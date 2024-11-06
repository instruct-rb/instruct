# Instruct

Instruct LLMs to do what you want


# How it works

```ruby
# normal control flow
lm = Instruct::LM.new(model: 'davinci')
lm += 'Please think of 5 different animals on separate lines.'
5.times do |i|
  lm += lm.f{"Animal #{i+1}"} + lm.gen(arr_name: :animals, name: :animal, stop: '\n')
end
puts lm[:animals] # ['dog', 'cat', 'bird', 'fish', 'snake']
puts lm[:animal] # 'snake'
```
class RandomishColorChooser


    def choose_a_color(lm, like_a = "fire-engine")

        # this overrides the system prompt for the next llm prompt, however it doesn't call the llm
        # lm is immutable, but using += returns a copy of the lm with the new prompt appended
        lm += lm.system { "your a helpful assistant" }

        # this appends a user prompt to the llm, but also doesn't call the llm
        lm += lm.user "please choose"
        # this appends another user prompt to the llm, but also doesn't call the llm
        lm += "a color"

        # this adds an assistant prompt "Like a fire-engine, I choose"
        # then it calls the llm with the prompt history including the assistant prompt
        # the lm.select stores the result in the lm[:color] variable
        lm.assistant += "Like a <%= like_a %>, I choose <%= lm.select('red', 'blue', 'green', name: :color)} %>"
        puts lm[:color] # 'red'
        puts lm.last_completion # 'Like a fire-engine, I choose red'
        like_a = "tree"
        lm = lm.assistant += "Like a <%= like_a %>, I choose <%= lm.select( 'red', 'blue', 'green', name: :color)}, it has <%= select('light '+ lm[:color], 'orange', name: :spot_color) %> spots."
        puts lm[:color] # 'green'
        puts lm[:spot_color] # 'light green'


        # returning an updated lm
        lm
    end



end
