# frozen_string_literal: true

require "rubygems"
require "bundler"
require "bundler/gem_tasks"
require "rake"
require "rake/testtask"
require "rubocop/rake_task"

begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  warn e.message
  warn "Run `bundle install` to install missing gems"
  exit e.status_code
end

# Test Task
Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.pattern = "test/**/test_*.rb"
  test.warning = false
end

# Rubocop Task
RuboCop::RakeTask.new

task :default => "test"
