# Setting up the OpenAI client

Add this line to your application's Gemfile:

```ruby
  gem 'ruby-openai'
```

If you would like to override the default OpenAI client configuration
options, you can set them in an initializer .

```ruby
# config/initializers/openai.rb - example rails initializer
OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.anthropic[:access_token]

  # As of 2024-12-13 you can set the following client configuration options:
  # config.api_type
  # config.api_version
  # config.access_token
  # config.organization_id
  # config.uri_base
  # config.request_timeout
  # config.extra_headers
end
```

Alternatively, instruct will use an access token set in `OPENAI_ACCESS_TOKEN` or
`OPENAI_API_KEY` environment variables.


# Using completions API instead of chat
The ruby-openai gem allows calls to be made to the completions endpoint instead
of the chat api. Currently `gpt-3.5-turbo-instruct` is the only model that uses
this API and OpenAI has marked it as deprecated, neverthless, if the gem is used
with a different base_uri, such as with a local model, you can force use of the
completions endpoint by setting the `use_completion_endpoint: true` keyword
argument when creating a model with `Instruct::OpenAI#new` or in a `#gen` call
that resolves to an `Instruct::OpenAI` model.
