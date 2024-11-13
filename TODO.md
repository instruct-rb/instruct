# Todos

- [ ] freeze strings
- [ ] Use an actual model
  - [ ] Load models using string
  - [ ] Override model for specific gen calls
- [-] Roles for chat completion
  - [-] Create a role system
  - [-] Work out an escaping system for user content
- [ ] Add deferred to lm
  - Why?
    - That way a function doesn't have to have an lm passed in
    - Ideas?
      - can we return a normal result from the function? or does it have to be an lm?
    - This could just return a SumExpression
- [ ] Transcript
  - [ ] Make it an object
  - [ ] Calculate forked paths
  - [ ] Store failed constraints
  - [ ] Store details of LLM call
- [ ] Streaming responses
  - Why?
    - Useful for displaying a transcript as it's being generated
    - Once we work out how our constraints model works, we can
    stop a response that doesn't meet our constraints immediately
    and retry or stop
  - [ ] Create a streaming completion mockable model
  - [ ] Make streaming responses the default
    - Why?
  - [ ] Stream responses
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
      - XML xs schema useful for xml based responses
- [ ] Debugging
  - Why?
    - If we could create something like a stacktrace of the code + stacktrace of the LLM calls
      and their transcripts, we could make debugging llm "programs" much easier.
  - [ ] What would a stacktrace of LLM calls + stacktrace look like?
  - [ ] Visualize the transcript
  - [ ] Make it easy to take an llm program and debug it with evals
    - [ ] It should be easy to debug sub prompts
- [ ] Support Anthropic cached message
    - Idea is that you can use do user (cached: <opts>) in the prompt
- [ ] Guardrails
  - [ ] Async pre guards
  - Consider using promp_safe not just as a flag, but as an object which captures what checks have been done
    - This might work well as the way prompt_safe gets passed around in the middleware mappings could get
      complicated if there are other bits of data to be attached
  - Let the transcript keep track of any guards (pre and post), like jailbreaks, etc.
  - This way we don't have to keep track of them for multiple executions of the same prompt
  - Look at Nemo Guardrail from Nvidia for ideas

# Middleware
- [ ] add a way so that if a middleware runs another request and completion we can
  store that but without breaking the transcript. (perhaps we provide the current lm)
  and the middleware can call lm.gen(req) and return the response.
- [ ] add prompt_safe to #f() so that it can be set to override the default
  - [ ] write a test for this

# Chomp Middleware
- [ ] If the middleware hid some whitespace, and then the LLM adds it, perhaps we should
  hide the whitespace in the response, so that the captured variables are correct (don't hold the whitespace)

# Tidys
- [ ] Add a test helper for LM that just tests the transcript string
