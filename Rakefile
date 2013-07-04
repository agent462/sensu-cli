require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => [:spec, :rubocop]

task :test => [:spec, :rubocop]

task :rubocop do
  puts '================'
  sh 'rubocop'
end
