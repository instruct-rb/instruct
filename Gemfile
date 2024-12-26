source "https://rubygems.org"

gemspec

# optional production deps
gem "rainbow"
gem "ruby-openai"
gem "anthropic"

group :rails_only do
  gem "rails"
  gem "activejob"
end

group :jupyter do
  gem "iruby"
end
# development
gem "rake"
gem "minitest"
gem "attributed-string", github: "mackross/attributed-string-rb", branch: "main"

# documentation server
gem "yard"
gem "webrick"
gem "rdoc"
