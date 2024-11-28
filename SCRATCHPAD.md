The instruct aims to make working directly with LLMs via prompt and responses seamless
and interwoven with code, the plans to build an ecosystem
of tools on top of it.

It's goal is to provide a great DX for working with LLMs in Ruby from development to production,
simple prompts to automated prompt optimization, free form output to structured output.

Big ideas....
See instruct-eval for a framework for evaluating prompts and collecting samples
See instruct-web for a web interface for developing prompts with evals
See instruct-spygrad gem for automatic prompt optimization (dspy and textgrad inspired)
See instruct-structured-output for structured output (instruct-spy depends on this) (baml inspired)
See instruct-guard for guardrails to stop prompt injections

# Stream Object Handling
NTS: How can different middlewares add their own stream handlers with potentially different output objects:
 i.e. stream.to_chat, stream.last_chunk, stream.response, stream.structured_output
 maybe it's just like an .env in the stream response object and if the middleware has a method with the same
 name it'll be called?

 TODO: think about function calling, how do we handle it? Probably tools are passed into gen()
 but they can also be attached to the transcript. Similar to how model is selected.

 Possibly you can define tools at a class level by just adding them to the class
 ```ruby
  class X
    define_tool :name, :function # this will be on every gen call for this class

    # this will be on all future gen calls for this transcript, unless the tool attachment is removed
    ts += tool(:function_name)

    gen(tools, tools_erb:,)
  end
  ```




# Todos

- [ ] Figure out model middleware vs user added middleware
- [ ] freeze strings
- [x] Use an actual model
  - [ ] Add anthropic
  - [ ] Load models using string
  - [ ] Override model for specific gen calls
- [ ] Roles for chat completion
  - [ ] Create a role system
  - [x] Work out an escaping system for user content
- [ ] Capture should be deferred
  - Why?
    - That way it could sit in the erb system and look at result of previous llm calls on the same prompt
    - That way function calls for CFGs could be created
- [x] Transcript
  - [x] Make it an object
  - [ ] Consider stopping the safe being modified with attrs or by appending attributed strings
  - [ ] Calculate forked paths
  - [ ] Store failed constraints
  - [ ] Store details of LLM call
- [x] Streaming responses
  - [ ] Stream object handler (like prompt object but the other way)
  - [ ] Client side stops
    - I think throw catch is the best way as that should close the request
    - see example https://github.com/alexrudall/ruby-openai/issues/265
    - client side retries could be done similarly
  - Why?
    - Useful for displaying a transcript as it's being generated
    - Once we work out how our constraints model works, we can
    stop a response that doesn't meet our constraints immediately
    and retry or stop
  - [x] Create a streaming completion mockable model
  - [x] Make streaming responses the default
    - Why?
  - [x] Stream responses
- [ ] Constraints
  - [ ] Regex constraints
    - Why?
      - Useful for constraining the output of small generations
    - [ ] Constrain finished gen with regex
  - [ ] Streaming constraints
    - Why?
      - This more powerful constraint system will allow us to
        constrain the output based on the streamed response.
        - When running on an endpoint we can constrain the token choices
        - When running against a streaming API this lets us quickly determine
          if the response is valid, allowing us to terminate and possibly retry
          from the last valid point.
    - Research:
      - Parslet https://kschiess.github.io/parslet/documentation.html
      - PEG parsers
      - CFGs
        https://github.com/famished-tiger/Rley
    - Ideas
      - XML / HTML might be a nice way to display attributed strings
- [ ] Debugging
  - Why?
    - If we could create something like a stacktrace of the code + stacktrace of the LLM calls
      and their transcripts, we could make debugging llm "programs" much easier.
  - [ ] What would a stacktrace of LLM calls + stacktrace look like?
  - [ ] Visualize the transcript
    - [x] Visualize in the console with colors
    - [ ] Connect to instruct-web with middleware
    - [ ] Stream responses in instruct-web view with actioncable
  - [ ] Make it easy to take an llm program and debug it with evals
    - [ ] It should be easy to debug sub prompts
- [ ] Support Anthropic cached message
    - Idea is that you can use do user (cached: <opts>) in the prompt
- [ ] Guardrails
  - [ ] Async pre guards
  - Consider using promp_safe not just as a flag, but as an object which captures what checks have been done
    - This might work well as the way safe gets passed around in the middleware mappings could get
      complicated if there are other bits of data to be attached
  - Let the transcript keep track of any guards (pre and post), like jailbreaks, etc.
  - This way we don't have to keep track of them for multiple executions of the same prompt
  - Look at Nemo Guardrail from Nvidia for ideas

# Middleware
- [ ] add a way so that if a middleware runs another request and completion we can
  store that but without breaking the transcript. (perhaps we provide the current lm)
  and the middleware can call lm.gen(req) and return the response.
- [ ] Add a way for middleware to be passed to the call or gen method
  - [ ]  Middleware should be able to figure out their correct order
    - [ ] Allow middleware to define upstream and downstream candidates (nil is directly on the model or directly on the transcript)
- [x] add safe to #() so that it can be set to override the default: ALTERNATE FOUND

# Chomp Middleware
- [ ] If the middleware hid some whitespace, and then the LLM adds it, perhaps we should
  hide the whitespace in the response, so that the captured variables are correct (don't hold the whitespace)

# Tidys
- [ ] Add a test helper for LM that just tests the transcript string
