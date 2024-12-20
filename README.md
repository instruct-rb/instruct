# Instruct
*Instruct LLMs to do what you want in Ruby.*

Combine **code**, **prompts**, and **completions** in a natural and intuitive
way for programmers. Inspired by libraries like
[Guidance](https://github.com/guidance-ai/guidance) and rack, Instruct strips
away boilerplate code while providing a flexible and powerful interface that
doesn't abstract away control over the LLM.


## Features

* **Natural and Intuitive API**
  
  Using LLMs with instruct is not too different from plain old string
  manipulation. This lets you think about your prompts and completions in a way
  that intuitively makes sense to most programmers.
* **Safe Prompting**
  
  The ERB `#p{}`rompt helper can be used to generate prompts with dynamic input in an
  familiar way. Dynamic input is automatically marked as unsafe and can be
  handled differently by middleware (for example to check for prompt
  injections). Use `.prompt_safe` to mark part of the prompt as safe.
* **Flexible Middleware Stack**
  
  Middleware can be used to add features like structured output, conversation
  pruning, RAG integrations, retries, auto-continuation, guard-rails, monitoring
  and more. The middleware stack also provides a common way to transform a prompt for
  different LLM models with different capabilities.
* **Streaming Support**
  
  Both middleware and callers can process completion responses as the chunks
  arrive. This can be used to display a completion in real time, or to validate
  or parse the output of an LLM call as it's being generated.
* **Rails Integration**
  
  Prompts, completions and models can be serialized and stored on ActiveRecord
  with custom attributes and will automatically serialize when passed to an
  ActiveJob. Enabling easy background processing of LLM calls.

---
🏗️ **This gem is still undergoing active development and is not yet ready for use
beyond experimentation.**

I'm making this public to get feedback and to see if there is any interest in
from the community to help develop this further.

---

## Installation

This gem won't be published again to RubyGems until it's more stable. For now, you
should add these lines to your application's Gemfile to experiment with Instruct:

```ruby
  gem "instruct", github: "instruct-rb/instruct", branch: "development"
  gem "attributed-string", github: "instruct-rb/attributed-string", branch: "main"
```

Include the helpers and refinements in the modules or classes where you want to
use Instruct.

```ruby
  include Instruct::Helpers
  using Instruct::Refinements
```

Instruct supports the ruby-openai gem and anthropic out of the box, simply include the
one or both gems in your Gemfile.

```ruby
  gem "ruby-openai"
  gem "anthropic"
```

For more info on setting up the OpenAI or Anthropic clients, see the docs for
[OpenAI Usage](docs/openai-usage.md) and [Anthropic Usage](docs/anthropic-usage.md).

## Usage

### The gen function

`gen` is used to **gen**erate completions from an LLM.

### Simple Usage

Getting a single completion from an LLM is as simple as calling `gen` with a prompt.

When a prompt is a present as the first argument the gen call immediately
retrieves the completion from the LLM.

The model can be set with the model keyword argument if no default model has been
set. Similarly all arguments that `ruby-openai` and `anthropic` can be configured with
can be passed into the gen call.
```ruby
completion = gen("The capital of France is ", stop_chars: "\n ,.", model: 'gpt-3-5-turbo-instruct')

puts completion # => "Paris"
```

### Deferred Completions

The gen function can also create deferred completions. This is used to create
prompts that can be called multiple times or passed around as an argument.

```ruby

  # Adding gen to a string creates a deferred completion. This is indicated by
  # the 💬 emoji.
  prompt = "The capital of France is " + gen(stop_chars: "\n ,;.") + "!"

  puts prompt # => "The capital of France is 💬!"

  # Each time the prompt is called, a new completion is generated and returned.
  completion = prompt.call

  puts completion # => "Paris"

  # When a completion is added to the prompt that generated it, a new
  # prompt is created with the completion replacing the deferred completion.
  puts prompt + completion # => "The capital of France is Paris!"

  # Note the exclamation mark is still present and comes after the completion.
```

### Appending to an existing prompt

The double angle bracket operator `<<` can be used to quickly append objects
to a prompt. This can be used to modify and build up a prompt in place.

Unlike the `+=` and `concat` operators, the `<<` operator will immediately call any
deferred completions and append them to the prompt.

```ruby
  string = Instruct::Prompt.new
  string << "The capital of France is "
  string << gen(stop_chars: "\n ,;.") + "!"

  puts string # => "The capital of France is Paris!"

  string << " It is widely known for " + gen(stop_chars: ".") + "."
  puts string # => "The capital of France is Paris! It is widely known for its fashion, art and culture."
```

### Capturing Generated Completion

Because it's quite common to want to access a completion, but not break apart
the prompt and completion into separate components, instruct provides `capture`
captures the result of a completion from a deferred generation and makes it
accessible from the prompt with `captured`.

```ruby
  string = Instruct::Prompt.new
  string << "The capital of France is " + gen(stop: '\n','.').capture(:capital)

  puts string.captured(:capital) # => "Paris"
```

Passing a `list: :key` keyword argument will capture an array of completions under the same key.

### Creating a Prompt Transcript

Most modern LLMs are designed for conversational style completions. The chat
completion middleware transforms a prompt formatted like a transcript into an
object that can be used with these APIs.
```ruby
  # Roles can be added to a prompt transcript by a new line with the role name
  # followed by a colon and then a space.
  transcript = p{"
    system: You're an expert geographer that speaks only French
    user: What is the capital of Australia?
  "} + gen(prompt, stop_chars: "\n ,;.", model: 'gpt-4o')


  # Note the returned or captured completion does not include any role prefix.
  completion = transcript.call
  puts completion # => "le capital de l'Australie est Canberra"

  # However, when the completion is added to the transcript, the `assistant: `
  # prefix is automatically prepended (if required), enabling a new user prompt
  # to be appended immediately after.
  puts transcript + completion
  # => "system: You're an expert geographer that speaks only French
  #     user: What is the capital of Australia?
  #     assistant: le capital de l'Australie est Canberra"
```

If you want to be more explicit about adding roles in to a prompt, instruct provides
`#p.system`, `#p.user`, and `#p.assistant` helper methods. There is nothing
special about these methods, they just prepend the role prefix to the string

```ruby
  transcript = p.system{"You're an expert geographer that speaks only French"}
  transcript += p.user{"What is the capital of Australia?"}
  transcript += gen(stop_chars: "\n ,;.", model: 'gpt-4o')
```

### The p(rompt) Block ERB Helper

`#p{}` (shown above) allows for dynamic prompt templating using ERB tags
`<%= %>` with automatic handling of safe and unsafe content similar to HTML
templating.

This safety mechanism provides a way for both programmer and middleware to tell
the difference between user, LLM, and prompt template text. In the case of the
Chat Completion Middleware, role switches cannot occur in unsafe text.

Similarly, guard middleware might be added to check unsafe content for prompt
injections or innapropriate content.

ERB heredoc blocks combined with the `p` helper provide syntax highlighting
in most editors making long dynamic prompts easy to read. The following prompt
shows how to use a chomped ERB heredoc to generate larger prompts with both
"safe" and "unsafe" content.

```ruby
  p = p{<<~ERB.chomp
      This is a longer prompt, if the included content might include
      injections use the normal ERB tags like so: <%= unsafe_user_content %>.

      If we know that something doesn't include prompt injections, add it
      as: <%= raw some_safe_content %>, #{some_safe_content} or <%=
      some_safe_string.prompt_safe %>.

      By default generated LLM responses as <%= gen %> or #{ gen } will be added
      to the prompt as unsafe. To add it as safe we cannot use the ERB
      method, we instead need to call .prompt_safe on the completion befored
      appending it.
    ERB
  }
```

### A More Complex Example: Multi-Turn Conversations Between Agents

Here we put together all the features so far to show how you can easily manage multi-turn
interactions between two different agents.

```ruby
  # Create two agents: Noel Gallagher and an interviewer with a system prompt.
  noel = p.system{"You're Noel Gallagher. Answer questions from an interviewer."}
  interviewer = p.system{"You're a skilled interviewer asking Noel Gallagher questions."}

  # We start a dynamic Q&A loop with the interviewer by kicking off the
  # interviewing agent and capturing the response under the :reply key.
  interviewer << p.user{"__Noel sits down in front of you.__"} + gen.capture(:reply)

  puts interviewer.captured(:reply) # => "Hello Noel, how are you today?"

  5.times do
    # Noel is sent the last value captured in the interviewer's transcript under the :reply key.
    # Similarly, we generate a response for Noel and capture it under the :reply key.
    noel << p.user{"<%= interviewer.captured(:reply) %>"} + gen.capture(:reply, list: :replies)

    # Noel's captured reply is now sent to the interviewer, who captures it in the same way.
    interviewer << p.user{"<%=  noel.captured(:reply) %>"} + gen.capture(:reply, list: :replies)
  end

  # After the conversation, we can access the list captured replies from both agents
  noel_said = noel.captured(:replies).map{ |r| "noel: #{r}" }
  interviewer_said = interviewer.captured(:replies).map{ |r| "interviewer: #{r}" }

  puts interviwer_said.zip(noel_said).flatten.join("\n\n")
  # => "noel: ... \n\n interviewer: ..., ..."
```

## The Prompt
The following examples illustrate how the Prompt can be manipulated in
different ways.
``` ruby
  Instruct::Prompt.new << "The capital of France is" + gen(stop: '\n','.')
  # => "The capital of France is Paris"

  prompt = "The capital of France is" + gen(stop: '\n','.')
  # => "The capital of France is 💬"
  # Note that a prompt can just be created by adding a string and a gen
  # call. However, the gen call is deferred (as indicated by the 💬).

  prompt.class
  # => Instruct::Prompt

  result = prompt.call do |response|
    # This optional block on the call method can be used for streaming
    # The response is called after each chunk is processed by the middleware,
    # the response is the entire buffer so Paris as three chunks might look like
    # "P", "Par", "Paris". It's possible that middleware could change the
    # response, so it's best not to treat these as final until after the call is
    # finished.
  end
  # => "Paris"

  result.class
  # => Instruct::Prompt::Completion

  result.prompt
  # => "The capital of France is 💬"


  result.prompt == prompt
  # => true

  together = prompt + result
  # => "The capital of France is Paris"
  # Adding a completion to a prompt will return the prompt with the completion appended.
  # If this completion was generated using the same prompt, it will also update the prompts
  # content with any additional changes that were made by middleware during
  # the call that produced the completion. This includes transferring the captured values.

  together.class
  # => Instruct::Prompt

  # This does nothing as there are no deferred calls.
  together.call
  # => nil

  prompt = "The capital of Germany is" + gen(stop: '\n','.') + ", which is in the region of " + gen(stop: '\n','.')
  # => "The capital of Germany is 💬, which is in the region of 💬"

  result = prompt.call
  # => [ "Berlin", "Europe" ] # Array<Instruct::Prompt::Completion>

  new_prompt == Instruct::Serializer.load(Instruct::Serializer.dump(prompt))
  # => "The capital of Germany is 💬, which is in the region of 💬"

  new_prompt == prompt
  # => true

  # The results are joined together with the prompt in the order they were returned.
  together = new_prompt + result
  # => "The capital of Germany is Berlin, which is in the region of Europe"

  # The interpolation only occurs if the prompt that generated the completion(s)
  # is equal to the prompt that is being added or concatenated to. In all other
  # cases the completion is added to the end of the prompt.
```

## Logging Setup
`Instruct.error_logger` and `Instruct.logger` can be set to any ruby `Logger`
class. By default they are configured to log warn and error messages. Set the `INSTRUCT_LOG_LEVEL`
environment variable to `debug`, `info`, `warn`, `error`, `fatal`, `unknown` to change the
the log level, or change the log level directly on the logger instance.

```ruby
# logs errors and warnings to STDERR by default, by default all warnings and
# errors are logged
Instruct.err_logger.sev_threshold = :warn

# logs all debug and info messages to STDOUT, by default nothing is logged as
# the default is warn.
Instruct.logger.sev_threshold = :warn
```


## What's missing
This gem is still in development and is missing many features before a 1.0,
please feel free to get in touch if you would like to contribute or have any
ideas.

- Middleware
  - [ ] Constraint based validation with automatic retries
  - [ ] Improvments to chat completion middleware
    - [ ] Allow role switching on the same line but then in the updated prompt fix it
    - [ ] New Conversation middleware with default to user with system kw arg or assistant kw arg (maybe its one and the same?)
  - [ ] Conversation management (prune long running conversations)
  - [ ] Async support (waiting on async support in ruby-openai). This enables
        the use of async calls to the LLM and the use of async middleware.
  - [ ] Streaming structured output (similar to BAML or a CFG)
    - [ ] Self healing
  - [ ] Guard-rails (middleware that checks for prompt injections/high perplexity)
  - [ ] Auto-continuation (middleware that adds prompts to continue a conversation)
  - [ ] Support transform attachments in the prompt intos multi-modal input
  - [ ] Anthropic caching
  - [ ] Visualize streaming prompt as a tree in web interface (dependent on forking)
  - [ ] Standardize finish reasons, and shared call arguments
- Models
  - [x] OpenAI API model selection
  - [x] Anthropic API model selection
  - [ ] Gemini models
  - [ ] Local models
    - [ ] Constrained inference like Guidance
    - [ ] Token healing
- Core
  - [ ] Track forking path
  - [ ] Change middleware by passing it into the gen or call methods
  - [ ] Tool calling
    - [ ] Develop an intuitive API for calling tools
  - [ ] Batch APIs
  - [ ] Improve attributed string API with a visitor style presenter
    - [ ] Update middleware and printers to use the new presenters
  - [x] Serialization of prompts (Consider migrations / upgrades) for storage
    - [x] Register ActiveJob serializer for prompts so that they can be added to the job queue
    - [ ] Register ActiveRecord serializer for prompts so that they can be stored in the database
  - [x] `stop_chars` and `stop`
