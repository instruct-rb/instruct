# Instruct

Instruct LLMs to do what you want


# How it works

```ruby
# add ints using an llm
a, b = 1, 2
lm = Instruct::LM.new(model: 'davinci')
lm += lm.f{"#{a} + #{b} = "} + lm.gen(regex=/\d+/, name: :sum)
puts lm[:sum].to_i # prints 3
puts lm.transcript_string # prints "1 + 2 = 3"
```

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
