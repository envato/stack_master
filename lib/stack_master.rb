require "commander"
require "yaml"
require "virtus"
require "aws-sdk"

require "stack_master/version"
require "stack_master/stack"
require "stack_master/utils"
require "stack_master/config_loader"
require "stack_master/config/stack_definition"
require "stack_master/config/stack_definitions"
require "stack_master/command"
require "stack_master/commands/apply"

module StackMaster
end
