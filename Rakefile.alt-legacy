# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"
RuboCop::RakeTask.new

task default: %i[test rubocop]

desc "Run tests"
task :test do
  sh "ruby test_runner.rb"
end
