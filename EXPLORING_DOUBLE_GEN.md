  ```ruby
  "The capital of France is" << gen(stop: '\n','.')
  # => "The capital of France is Paris"

  prompt =  "The capital of France is" + gen(stop: '\n','.')
  # "The capital of France is [LLM Gen]"

  result = prompt.call
  # => "Paris" (GenStringResult < String) * Start by making this the same class as Transcript
  # This is the same as result = "" << prompt, it should be noted that << returns itself and not the result of the call

  result.prompt
  # => "The capital of France is [LLM Gen]"

  result.prompt == prompt

  together = prompt + result # NTS: (maybe only possible if result.prompt == prompt? but also maybe it just works)
  # => "The capital of France is Paris"

  together.last_gen == result
  # true

  together.call # does nothing as there are no deferred calls
  # nil

  prompt = "The capital of Germany is" + gen(stop: '\n','.') + ", which is in the region of " + gen(stop: '\n','.')
  # => "The capital of Germany is [LLM Gen], which is in the region of [LLM Gen]"

  result = prompt.call
  # => [ "Berlin", "Europe" ] (Array (of GenStringResults))

  # The first element in this array will have a prompt that equals "The capital of Germany is [LLM Gen]", but the second
  # will not match as the prompt is based on the generation. It could be split in to two calls.
  result[0].prompt = "The capital of Germany is [LLM Gen]"
  result[1].prompt = "The capital of Germany is Berlin, which is in the region of [LLM Gen]"
#  NTS: when a prompt and result are added if its an array it just pops it on to the prompt bits

# if i were to call twice in a row, I would expect different results, but for the two to be consistent
# it feels to me that the prompt should be immutable, which means that the result needs to hold the updated transcript
# and the new result. in the example with two generations, the first result should update the transcript to the first
# generation, but the second generation, should update the whole transcript.
# this means that a result holds itself and its transcript. Adding the result, just returns the modified transcript + the result

  together = prompt + result # TODO: what should result + prompt do or result + result?
  # => "The capital of Germany is Berlin, which is in the region of Europe"
