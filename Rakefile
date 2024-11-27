# frozen_string_literal: true

require "bundler/gem_tasks"
require "rubocop/rake_task"
RuboCop::RakeTask.new

task default: %i[test rubocop copy_coverage]

desc "Run tests"
task :test do
  sh "ruby test_runner.rb"
end

desc "Copy coverage report to public"
task :copy_coverage do
  FileUtils.cp("coverage/coverage_badge_total.svg", "./coverage_badge.svg")
end
