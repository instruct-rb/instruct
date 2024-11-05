require_relative "lib/instruct/version"

Gem::Specification.new do |spec|
  spec.name          = "instruct"
  spec.version       = Instruct::VERSION
  spec.summary       = "Instruct LLMs to do what you want"
  spec.homepage      = "https://github.com/mackross/instruct"
  spec.license       = "Apache-2.0"

  spec.author        = "Andrew Mackross"
  spec.email         = "andrew@mackross.net"

  spec.files         = Dir["*.{md,txt}", "{lib,licenses}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 3.1"
end
