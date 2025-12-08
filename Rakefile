require "bundler/gem_tasks"
require 'bundler/setup'

task :environment do
  require 'stack_master'
end

task :console => :environment do
  require 'pry'
  binding.pry
end

# Add specs and features tests
begin
  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
  end

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = "--format doc"
  end

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new('rubocop')
rescue LoadError
end

task :default => [:features, :spec, :rubocop]
