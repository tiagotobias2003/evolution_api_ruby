# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['--display-cop-names']
end

YARD::Rake::YardocTask.new(:yard) do |task|
  task.options = ['--readme', 'README.md']
end

task default: %i[rubocop spec]

desc 'Run all checks'
task check: %i[rubocop spec yard]

desc 'Build the gem'
task build: [:spec] do
  Rake::Task['build'].invoke
end

desc 'Install the gem'
task install: [:build] do
  Rake::Task['install'].invoke
end

desc 'Release the gem'
task release: [:check] do
  Rake::Task['release'].invoke
end
