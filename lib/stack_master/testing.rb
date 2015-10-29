require 'stack_master'

Aws.config[:stub_responses] = true

require 'stack_master/test_driver/cloud_formation'

StackMaster.cloud_formation_driver = StackMaster::TestDriver::CloudFormation.new
