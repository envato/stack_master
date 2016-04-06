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
require 'ruby-progressbar'

require "stack_master/ctrl_c"
require "stack_master/command"
require "stack_master/version"
require "stack_master/stack"
require "stack_master/prompter"
require "stack_master/aws_driver/cloud_formation"
require "stack_master/test_driver/cloud_formation"
require "stack_master/stack_events/fetcher"
require "stack_master/stack_events/presenter"
require "stack_master/stack_events/streamer"
require "stack_master/stack_states"
require "stack_master/stack_status"
require "stack_master/sns_topic_finder"
require "stack_master/security_group_finder"
require "stack_master/parameter_loader"
require "stack_master/parameter_resolver"
require "stack_master/resolver_array"
require "stack_master/parameter_resolvers/stack_output"
require "stack_master/parameter_resolvers/secret"
require "stack_master/parameter_resolvers/sns_topic_name"
require "stack_master/parameter_resolvers/security_group"
require "stack_master/parameter_resolvers/latest_ami_by_tags"
require "stack_master/utils"
require "stack_master/config"
require "stack_master/paged_response_accumulator"
require "stack_master/stack_definition"
require "stack_master/template_compiler"
require "stack_master/template_compilers/sparkle_formation"
require "stack_master/template_compilers/json"
require "stack_master/template_compilers/yaml"
require "stack_master/template_compilers/cfndsl"
require "stack_master/commands/terminal_helper"
require "stack_master/commands/apply"
require "stack_master/change_set"
require "stack_master/commands/events"
require "stack_master/commands/outputs"
require "stack_master/commands/init"
require "stack_master/commands/diff"
require "stack_master/commands/list_stacks"
require "stack_master/commands/validate"
require "stack_master/commands/resources"
require "stack_master/commands/delete"
require "stack_master/commands/status"
require "stack_master/stack_differ"
require "stack_master/validator"
require "stack_master/cli"

module StackMaster
  extend self

  def interactive?
    !non_interactive?
  end

  def non_interactive?
    @non_interactive
  end
  @non_interactive = false

  def non_interactive!
    @non_interactive = true
  end

  def debug!
    @debug = true
  end
  @debug = false

  def debug?
    @debug
  end

  def debug(message)
    return unless debug?
    stderr.puts "[DEBUG] #{message}".colorize(:green)
  end

  attr_accessor :non_interactive_answer
  @non_interactive_answer = 'y'

  def base_dir
    File.expand_path(File.join(File.dirname(__FILE__), ".."))
  end

  def cloud_formation_driver
    @cloud_formation_driver ||= AwsDriver::CloudFormation.new
  end

  def cloud_formation_driver=(value)
    @cloud_formation_driver = value
  end

  def stdout
    @stdout || $stdout
  end

  def stdout=(io)
    @stdout = io
  end

  def stdin
    $stdin
  end

  def stderr
    @stderr || $stderr
  end

  def stderr=(io)
    @stderr = io
  end
end

