require "commander"
require "yaml"
require "aws-sdk"
require "colorize"
require 'active_support/core_ext/string'

module StackMaster
  extend self

  autoload :Initializable, 'stack_master/utils/initializable'
  autoload :ChangeSet, 'stack_master/change_set'
  autoload :CLI, 'stack_master/cli'
  autoload :CtrlC, 'stack_master/ctrl_c'
  autoload :Command, 'stack_master/command'
  autoload :VERSION, 'stack_master/version'
  autoload :Stack, 'stack_master/stack'
  autoload :Prompter, 'stack_master/prompter'
  autoload :StackStates, 'stack_master/stack_states'
  autoload :StackStatus, 'stack_master/stack_status'
  autoload :SnsTopicFinder, 'stack_master/sns_topic_finder'
  autoload :SecurityGroupFinder, 'stack_master/security_group_finder'
  autoload :ParameterLoader, 'stack_master/parameter_loader'
  autoload :ParameterResolver, 'stack_master/parameter_resolver'
  autoload :ResolverArray, 'stack_master/resolver_array'
  autoload :Resolver, 'stack_master/resolver_array'
  autoload :Utils, 'stack_master/utils'
  autoload :TemplateUtils, 'stack_master/template_utils'
  autoload :Config, 'stack_master/config'
  autoload :PagedResponseAccumulator, 'stack_master/paged_response_accumulator'
  autoload :StackDefinition, 'stack_master/stack_definition'
  autoload :TemplateCompiler, 'stack_master/template_compiler'

  autoload :StackDiffer, 'stack_master/stack_differ'
  autoload :Validator, 'stack_master/validator'

  require 'stack_master/template_compilers/sparkle_formation'
  require 'stack_master/template_compilers/json'
  require 'stack_master/template_compilers/yaml'
  require 'stack_master/template_compilers/cfndsl'

  module Commands
    autoload :TerminalHelper, 'stack_master/commands/terminal_helper'
    autoload :Apply, 'stack_master/commands/apply'
    autoload :Events, 'stack_master/commands/events'
    autoload :Outputs, 'stack_master/commands/outputs'
    autoload :Init, 'stack_master/commands/init'
    autoload :Diff, 'stack_master/commands/diff'
    autoload :Stackify, 'stack_master/commands/stackify'
    autoload :ListStacks, 'stack_master/commands/list_stacks'
    autoload :Validate, 'stack_master/commands/validate'
    autoload :Resources, 'stack_master/commands/resources'
    autoload :Delete, 'stack_master/commands/delete'
    autoload :Status, 'stack_master/commands/status'
  end

  module ParameterResolvers
    autoload :AmiFinder, 'stack_master/parameter_resolvers/ami_finder'
    autoload :StackOutput, 'stack_master/parameter_resolvers/stack_output'
    autoload :Secret, 'stack_master/parameter_resolvers/secret'
    autoload :SnsTopicName, 'stack_master/parameter_resolvers/sns_topic_name'
    autoload :SecurityGroup, 'stack_master/parameter_resolvers/security_group'
    autoload :LatestAmiByTags, 'stack_master/parameter_resolvers/latest_ami_by_tags'
    autoload :LatestAmi, 'stack_master/parameter_resolvers/latest_ami'
  end

  module AwsDriver
    autoload :CloudFormation, 'stack_master/aws_driver/cloud_formation'
    autoload :S3, 'stack_master/aws_driver/s3'
  end

  module TestDriver
    autoload :CloudFormation, 'stack_master/test_driver/cloud_formation'
    autoload :S3, 'stack_master/test_driver/s3'
  end

  module StackEvents
    autoload :Fetcher, 'stack_master/stack_events/fetcher'
    autoload :Presenter, 'stack_master/stack_events/presenter'
    autoload :Streamer, 'stack_master/stack_events/streamer'
  end

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

  def s3_driver
    @s3_driver ||= AwsDriver::S3.new
  end

  def s3_driver=(value)
    @s3_driver = value
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
