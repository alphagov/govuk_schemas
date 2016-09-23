require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "gem_publisher"
require "yard"

RSpec::Core::RakeTask.new(:spec)

task default: [:spec]

desc "Publish gem to RubyGems"
task :publish_gem do |_t|
  published_gem = GemPublisher.publish_if_updated("govuk_schemas.gemspec", :rubygems)
  puts "Published #{published_gem}" if published_gem
end


YARD::Rake::YardocTask.new do |t|
  t.options = ['--no-private', '--markup', 'markdown', '--output-dir', 'docs']
end
