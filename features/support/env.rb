require 'aruba/cucumber'
require 'stack_master'
require 'stack_master/testing'
require 'aruba/processes/in_process'
require 'pry'
require 'cucumber/rspec/doubles'
require 'timecop'

Aruba.configure do |config|
  config.command_launcher = :in_process
  config.main_class = StackMaster::CLI
end

Before do
  StackMaster.cloud_formation_driver.reset
  StackMaster.s3_driver.reset
  StackMaster.reset_flags
  Timecop.travel(Time.local(2020, 10, 19))
end

After do
  Timecop.return
end

lib = File.join(File.dirname(__FILE__), "../../spec/fixtures/sparkle_pack_integration/my_sparkle_pack/lib")
$LOAD_PATH << lib
