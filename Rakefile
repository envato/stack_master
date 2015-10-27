require "bundler/gem_tasks"
require 'bundler/setup'

task :environment do
  require 'stack_master'
end

task :console => :environment do
  require 'pry'
  binding.pry
end
