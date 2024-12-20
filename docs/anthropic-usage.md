# Setting up the Anthropic client

Add this line to your application's Gemfile:

```ruby
  gem "anthropic"
```

If you would like to override the default anthropic client configuration
options, you can set them in an initializer .

```ruby
# config/initializers/anthropic.rb - example rails initializer
Anthropic.configure do |config|
  config.access_token = Rails.application.credentials.anthropic[:access_token]

  # As of 2024-12-12 you can set the following client configuration options:
  # config.access_token
  # config.api_version
  # config.anthropic_version
  # config.uri_base
  # config.request_timeout
  # config.extra_headers
end
```

Alternatively, instruct will use an access token set in `ANTHROPIC_ACCESS_TOKEN` or
`ANTHROPIC_API_KEY` environment variables.


Finally, you can override the client configuaration when creating a model or in a gen call.
```ruby
  # Setting the client configuration when creating a model
  Instruct::Anthropic.new('claude-3-5-sonnet-latest', access_token: '...', api_version: '...', anthropic_version: '...', uri_base: '...', request_timeout: 120, extra_headers: { ... })

  # Setting the client configuration in the gen call
  "The capital of france is " + gen(model: 'claude-3-5-sonnet-latest', access_token: '...', api_version: '...', anthropic_version: '...', uri_base: '...', request_timeout: 120, extra_headers: { ... })
```


# Model Selection
Instruct makes it easy to set default models and switch them as needed. You can
use a string model name or an Instruct::Anthropic instance anywhere a model can be set.

## Setting a default model
```ruby
  # If the model name contains claude and the anthropic gem has been loaded an Instruct::Anthropic instance will be created
  Instruct.default_model = 'claude-3-5-sonnet-latest'

  # This is the same as the above
  Instruct.default_model = Instruct::Anthropic.new('claude-3-5-sonnet-latest')
```

## Overriding the default model in a class
```ruby
  class MyModel
    include Instruct::Helpers
    using Instruct::Refinements

    # Set the default model for this class
    self.instruct_default_model = 'claude-3-5-sonnet-latest'

    # This is the same as the above
    self.instruct_default_model = Instruct::Anthropic.new('claude-3-5-sonnet-latest')
  end
```

## Overriding the default model of the class or application in a prompt
```ruby
  # This overrides the default model set in the class or application
  "The capital of france is " + gen(model: 'claude-3-5-sonnet-latest')

  # This is the same as the above
  "The capital of france is " + gen(model: Instruct::Anthropic.new('claude-3-5-sonnet-latest'))

```

## Overriding the default model of the class, application, or prompt in the call method
```ruby
  prompt = "The capital of france is " + gen('claude-3-5-haiku-latest')

  # This will use claude-3-5-haiku-latest regardless of the default model set in the class or application
  prompt.call

  # This will use claude-3-5-sonnet-latest
  prompt.call(model: 'claude-3-5-sonnet-latest')

  # This is the same as above
  prompt.call(model: Instruct::Anthropic.new('claude-3-5-sonnet-latest'))
```

# Default Max Tokens
If the model name includes claude-3-5-sonnet, instruct will set the default max
tokens to 8192. Otherwise for all other models it's set to 4096. See the
anthropic documentation for the max tokens for each model. It's a required field

# Advanced

## Using a client to create a model
This method allows you to completely customize the client used by the model, but
if used, does not allow for overriding the client configuration options in the
gen call.
```ruby
  client = Anthropic::Client.new(access_token: 'your_access_token')

  # ... wrap the client or do other things to it

  model = Instruct::Anthropic.new(client, model: 'claude-3-5-sonnet-latest')


  # Will raise an ArgumentError, as client configuration options cannot be set
  # in the gen call if a client is used to create the model
  "The capital of france is " + gen(model: model, beta: 'beta1')
```

Note that models instantiated with client directly cannot be serialized. This
applies to gen calls in a prompt which hold a handle to the model. Instead
you will need to save the prompt  without a deferred gen call and add it in
the background job or at the calling location.

## Beta option
Instruct sets the `anthropic-beta` headers on the anthropic client if the beta:
option is set in a gen call or model instantiation. This option will raise an
ArgumentError if the model was instantiated with a ::Anthropic::Client. If you
use a client to create a model you will need to set the headers on the client
yourself.
``` ruby
  # Used when creating a model explicitly
  model = Instruct::Anthropic.new('claude-3-5-sonnet-latest', beta: ["beta1", "beta2"])

  # Used when calling gen
  gen(model: `claude-3-5-sonnet-latest`, beta: "beta1")
```
