require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = FileList["test/**/*_test.rb"].exclude("test/openai/*_test.rb").exclude("test/anthropic/*_test.rb")
end

namespace :test do
  Rake::TestTask.new(:openai) do |t|
    t.libs << "test"
    t.pattern = FileList["test/openai/*_test.rb"]
  end
  Rake::TestTask.new(:anthropic) do |t|
    t.libs << "test"
    t.pattern = FileList["test/anthropic/*_test.rb"]
  end
end


namespace :docs do
  desc "Start YARD documentation server"
  task :server, [:port] do |t, args|
    port = args[:port] || 8808
    puts "Starting YARD server on http://localhost:#{port}"
    system("yard server -p #{port} -r")
  end
end
