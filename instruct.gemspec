require_relative "lib/instruct/version"

Gem::Specification.new do |spec|
  spec.name          = "instruct"
  spec.version       = Instruct::VERSION
  spec.summary       = "Instruct LLMs to do what you want"
  spec.homepage      = "https://github.com/mackross/instruct"
  spec.license       = "Apache-2.0"

  spec.author        = "Andrew Mackross"
  spec.email         = "andrew@mackross.net"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*", "LICENSE"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 3.2.3"


  # removing from std lib in ruby 3.5
  spec.add_dependency "ostruct"
  spec.add_dependency "mutex_m"
  spec.add_dependency "attributed-string"
end
