require 'commander'
require 'table_print'

module StackMaster
  class CLI
    include Commander::Methods

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
      Commander::Runner.instance_variable_set('@singleton', Commander::Runner.new(argv))
      StackMaster.stdout = @stdout
      StackMaster.stderr = @stderr
      TablePrint::Config.io = StackMaster.stdout
    end

    def default_config_file
      "stack_master.yml"
    end

    def execute!
      program :name, 'StackMaster'
      program :version, StackMaster::VERSION
      program :description, 'AWS Stack Management'

      global_option '-c', '--config FILE', String, 'Config file to use'
      global_option '--changed', 'filter stack selection to only ones that have changed'
      global_option '-y', '--yes', 'Run in non-interactive mode answering yes to any prompts' do
        StackMaster.non_interactive!
        StackMaster.non_interactive_answer = 'y'
      end
      global_option '-n', '--no', 'Run in non-interactive mode answering no to any prompts' do
        StackMaster.non_interactive!
        StackMaster.non_interactive_answer = 'n'
      end
      global_option '-d', '--debug', 'Run in debug mode' do
        StackMaster.debug!
      end

      command :apply do |c|
        c.syntax = 'stack_master apply [environment] [stack_name]'
        c.summary = 'Creates or updates a stack'
        c.description = "Creates or updates a stack. Shows a diff of the proposed stack's template and parameters. Tails stack events until CloudFormation has completed."
        c.example 'update a stack named myapp-vpc in us-east-1', 'stack_master apply us-east-1 myapp-vpc'
        c.option '--on-failure ACTION', String, "Action to take on CREATE_FAILURE. Valid Values: [ DO_NOTHING | ROLLBACK | DELETE ]. Default: ROLLBACK\nNote: You cannot use this option with Serverless Application Model (SAM) templates."
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Apply, args, options)
        end
      end

      command :outputs do |c|
        c.syntax = 'stack_master outputs [environment] [stack_name]'
        c.summary = 'Displays outputs for a stack'
        c.description = "Displays outputs for a stack"
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Outputs, args, options)
        end
      end

      command :init do |c|
        c.syntax = 'stack_master init [environment] [stack_name]'
        c.summary = 'Initialises the expected directory structure and stack_master.yml file'
        c.description = 'Initialises the expected directory structure and stack_master.yml file'
        c.option('--overwrite', 'Overwrite existing files')
        c.action do |args, options|
          options.defaults config: default_config_file
          unless args.size == 2
            say "Invalid arguments. stack_master init [environment] [stack_name]"
          else
            StackMaster::Commands::Init.perform(options.overwrite, *args)
          end
        end
      end

      command :diff do |c|
        c.syntax = 'stack_master diff [environment] [stack_name]'
        c.summary = "Shows a diff of the proposed stack's template and parameters"
        c.description = "Shows a diff of the proposed stack's template and parameters"
        c.example 'diff a stack named myapp-vpc in us-east-1', 'stack_master diff us-east-1 myapp-vpc'
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Diff, args, options)
        end
      end

      command :events do |c|
        c.syntax = 'stack_master events [environment] [stack_name]'
        c.summary = "Shows events for a stack"
        c.description = "Shows events for a stack"
        c.example 'show events for myapp-vpc in us-east-1', 'stack_master events us-east-1 myapp-vpc'
        c.option '--number Integer', Integer, 'Number of recent events to show'
        c.option '--all', 'Show all events'
        c.option '--tail', 'Tail events'
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Events, args, options)
        end
      end

      command :resources do |c|
        c.syntax = 'stack_master resources [environment] [stack]'
        c.summary = "Shows stack resources"
        c.description = "Shows stack resources"
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Resources, args, options)
        end
      end

      command :list do |c|
        c.syntax = 'stack_master list'
        c.summary = 'List stack definitions'
        c.description = 'List stack definitions'
        c.action do |args, options|
          options.defaults config: default_config_file
          say "Invalid arguments." if args.size > 0
          config = load_config(options.config)
          StackMaster::Commands::ListStacks.perform(config)
        end
      end

      command :validate do |c|
        c.syntax = 'stack_master validate [environment] [stack_name]'
        c.summary = 'Validate a template'
        c.description = 'Validate a template'
        c.example 'validate a stack named myapp-vpc in us-east-1', 'stack_master validate us-east-1 myapp-vpc'
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Validate, args, options)
        end
      end

      command :status do |c|
        c.syntax = 'stack_master status'
        c.summary = 'Check the current status stacks.'
        c.description = 'Checks the status of all stacks defined in the stack_master.yml file. Warning this operation can be somewhat slow.'
        c.example 'description', 'Check the status of all stack definitions'
        c.action do |args, options|
          options.defaults config: default_config_file
          say "Invalid arguments. stack_master status" and return unless args.size == 0
          config = load_config(options.config)
          StackMaster::Commands::Status.perform(config)
        end
      end

      command :delete do |c|
        c.syntax = 'stack_master delete [environment] [stack_name]'
        c.summary = 'Delete an existing stack'
        c.description = 'Deletes a stack'
        c.example 'description', 'Delete a stack'
        c.action do |args, options|
          options.default config: default_config_file
          unless args.size == 2
            say "Invalid arguments. stack_master delete [environment] [stack_name]"
            return
          end
          execute_stacks_command(StackMaster::Commands::Delete, args, options)
        end
      end

      run!
    end

    def load_config(file)
      stack_file = file || default_config_file
      StackMaster::Config.load!(stack_file)
    rescue Errno::ENOENT => e
      say "Failed to load config file #{stack_file}"
      exit 1
    end

    def execute_stacks_command(command, args, options)
      command_results = []
      config = load_config(options.config)
      args = [nil, nil] if args.size == 0
      args.each_slice(2) do |environment, stack_name|
        environment = Utils.underscore_to_hyphen(environment)
        stack_name = Utils.underscore_to_hyphen(stack_name)
        stack_definitions = config.filter(environment, stack_name)
        if stack_definitions.empty?
          StackMaster.stdout.puts "Could not find stack definition #{stack_name} in environment #{environment}"
        end
        stack_definitions = stack_definitions.select do |stack_definition|
          StackStatus.new(config, stack_definition).changed?
        end if options.changed
        stack_definitions.each do |stack_definition|
          StackMaster.cloud_formation_driver.set_region(stack_definition.region)
          StackMaster.stdout.puts "Executing #{command.command_name} on #{stack_definition.stack_name} from #{stack_definition.environment} in #{stack_definition.region}"
          command_results.push command.perform(config, stack_definition, options).success?
        end
      end

      # Return success/failure
      command_results.all?
    end
  end
end
