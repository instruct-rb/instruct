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
  gem "iruby", github: "mackross/iruby", branch: "master"
  gem "rexml"
end
# development
gem "rake"
gem "minitest"
gem "attributed-string", github: "mackross/attributed-string-rb", branch: "main"

# documentation server
gem "yard"
gem "webrick"
gem "rdoc"
