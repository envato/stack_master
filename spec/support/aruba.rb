require 'aruba/rspec'
require 'aruba/processes/in_process'

Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class = StackMaster::CLI
end
