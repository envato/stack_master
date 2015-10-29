require 'aruba/cucumber'
require 'stack_master'
require 'stack_master/testing'
require 'aruba/in_process'

Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class = StackMaster::CLI
end

Before do
  StackMaster.cloud_formation_driver.reset
end
