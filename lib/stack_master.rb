require "commander"
require "yaml"
require "virtus"
require "aws-sdk"
require "diffy"
require "colorize"
require 'active_support/core_ext/string'
require 'sparkle_formation'

require "stack_master/version"
require "stack_master/stack"
require "stack_master/stack_events/fetcher"
require "stack_master/stack_events/streamer"
require "stack_master/stack_states"
require "stack_master/parameter_loader"
require "stack_master/parameter_resolver"
require "stack_master/parameter_resolvers/stack_output"
require "stack_master/utils"
require "stack_master/config"
require "stack_master/config/stack_definition"
require "stack_master/config/stack_definitions"
require "stack_master/command"
require "stack_master/commands/apply"
require "stack_master/commands/diff"
require "stack_master/stack_differ"

module StackMaster
end
