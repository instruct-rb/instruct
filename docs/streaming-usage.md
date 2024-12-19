# Streaming Usage

Instruct provides a streaming handler that can be passing a block to the call method
on a prompt.

```ruby
prompt = "Please describe the capital of France" + gen

completion = prompt.call do |streamed_reponse|
  puts streamed_response
end
# => Par
# => Paris is
# => Paris is the capit
# ...

# Note: completion has the same value as the last yield of the given block.
```

# Getting a streamed chunk
Depending on how you're processing the stream, you might just want the latest chunk.
Simply call streamed_response.get_chunk to get the latest chunk. This takes
an optional argument to get a specific chunk.

# Stopping a completion early
Sometimes you may want to cancel a completion during streaming, simply throw
`:cancel`. This will end the stream at this point (the server may still
continuing generating a completion depending on the API client, however any
further results will be discarded).

```ruby
completion = prompt.call do |streamed_reponse|
  if streamed_response.length >= 12
    throw :cancel
  end
end
puts completion # => "A half finis"
puts completion.finish_reason  # => :cancelled
```
# TODO: the above needs a test (and possibly an implementation)
