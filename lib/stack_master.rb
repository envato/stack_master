require "commander"
require "yaml"
require "virtus"
require "aws-sdk"
require "diffy"
require "colorize"
require "table_print"
require 'active_support/core_ext/string'
require "erb"
require 'sparkle_formation'
require 'dotgpg'

require "stack_master/version"
require "stack_master/stack"
require "stack_master/stack_events/fetcher"
require "stack_master/stack_events/streamer"
require "stack_master/stack_states"
require "stack_master/sns_topic_finder"
require "stack_master/parameter_loader"
require "stack_master/parameter_resolver"
require "stack_master/parameter_resolvers/stack_output"
require "stack_master/parameter_resolvers/secret"
require "stack_master/parameter_resolvers/sns_topic_name"
require "stack_master/utils"
require "stack_master/config"
require "stack_master/config/stack_definition"
require "stack_master/config/stack_definitions"
require "stack_master/template_compiler"
require "stack_master/command"
require "stack_master/commands/apply"
require "stack_master/commands/init"
require "stack_master/commands/diff"
require "stack_master/commands/list_stacks"
require "stack_master/commands/validate"
require "stack_master/stack_differ"
require "stack_master/validator"

module StackMaster
  def self.base_dir
    File.expand_path(File.join(File.dirname(__FILE__), ".."))
  end
end
