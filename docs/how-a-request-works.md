# Completion Model

An instruct completion model is used to generate completions. It often wraps
an API client.

## Building a Completion Model
A completion model is responsible for
- capturing default options (kwargs) at initialization.
- creating a default request environment from the merged options.
  - merging options (kwargs) at call time with captured options.
- based on the request environment, create a middleware stack that processes the request.
- handle the final call in the middleware stack
- create a subclass response object that can parse the stream response from the API client.


- How do we want to deal with string model names?

- How do we

# Middleware

A middleware modifies or handles a completion request and response.
Middleware can add prompt_transformers which modify the prompt object
  Perhaps this should be a request_transformer?
Perhaps middleware should have a say in the setup of the request environment?

Something like

Create a default req env at call
  - figure out what model instance is
  - ask model to modify req env and use (optionally remove) any options it needs
    - ask model to setup model middleware
  - pass req through middleware if they make a change mark changed, repass through middleware
  - when no middleware changes remain execute the request in middleware




A completion model should allow any API client options to be passed in when initializing the model.

Th
