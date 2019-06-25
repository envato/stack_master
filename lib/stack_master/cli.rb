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
      global_option '-q', '--quiet', 'Do not output the resulting Stack Events, just return immediately' do
        StackMaster.quiet!
      end

      command :apply do |c|
        c.syntax = 'stack_master apply [region_or_alias] [stack_name]'
        c.summary = 'Creates or updates a stack'
        c.description = "Creates or updates a stack. Shows a diff of the proposed stack's template and parameters. Tails stack events until CloudFormation has completed."
        c.example 'update a stack named myapp-vpc in us-east-1', 'stack_master apply us-east-1 myapp-vpc'
        c.option '--on-failure ACTION', String, "Action to take on CREATE_FAILURE. Valid Values: [ DO_NOTHING | ROLLBACK | DELETE ]. Default: ROLLBACK\nNote: You cannot use this option with Serverless Application Model (SAM) templates."
        c.option '--yes-param PARAM_NAME', String, "Auto-approve stack updates when only parameter PARAM_NAME changes"
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Apply, args, options)
        end
      end

      command :outputs do |c|
        c.syntax = 'stack_master outputs [region_or_alias] [stack_name]'
        c.summary = 'Displays outputs for a stack'
        c.description = "Displays outputs for a stack"
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Outputs, args, options)
        end
      end

      command :init do |c|
        c.syntax = 'stack_master init [region_or_alias] [stack_name]'
        c.summary = 'Initialises the expected directory structure and stack_master.yml file'
        c.description = 'Initialises the expected directory structure and stack_master.yml file'
        c.option('--overwrite', 'Overwrite existing files')
        c.action do |args, options|
          options.defaults config: default_config_file
          unless args.size == 2
            say "Invalid arguments. stack_master init [region] [stack_name]"
          else
            StackMaster::Commands::Init.perform(options.overwrite, *args)
          end
        end
      end

      command :diff do |c|
        c.syntax = 'stack_master diff [region_or_alias] [stack_name]'
        c.summary = "Shows a diff of the proposed stack's template and parameters"
        c.description = "Shows a diff of the proposed stack's template and parameters"
        c.example 'diff a stack named myapp-vpc in us-east-1', 'stack_master diff us-east-1 myapp-vpc'
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Diff, args, options)
        end
      end

      command :events do |c|
        c.syntax = 'stack_master events [region_or_alias] [stack_name]'
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
        c.syntax = 'stack_master resources [region] [stack_name]'
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
        c.syntax = 'stack_master validate [region_or_alias] [stack_name]'
        c.summary = 'Validate a template'
        c.description = 'Validate a template'
        c.example 'validate a stack named myapp-vpc in us-east-1', 'stack_master validate us-east-1 myapp-vpc'
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Validate, args, options)
        end
      end

      command :lint do |c|
        c.syntax = 'stack_master lint [region_or_alias] [stack_name]'
        c.summary = "Check the stack definition locally"
        c.description = "Runs cfn-lint on the template which would be sent to AWS on apply"
        c.example 'run cfn-lint on stack myapp-vpc with us-east-1 settings', 'stack_master lint us-east-1 myapp-vpc'
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Lint, args, options)
        end
      end

      command :compile do |c|
        c.syntax = 'stack_master compile [region_or_alias] [stack_name]'
        c.summary = "Print the compiled version of a given stack"
        c.description = "Processes the stack and prints out a compiled version - same we'd send to AWS"
        c.example 'print compiled stack myapp-vpc with us-east-1 settings', 'stack_master compile us-east-1 myapp-vpc'
        c.action do |args, options|
          options.defaults config: default_config_file
          execute_stacks_command(StackMaster::Commands::Compile, args, options)
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
        c.syntax = 'stack_master delete [region] [stack_name]'
        c.summary = 'Delete an existing stack'
        c.description = 'Deletes a stack. The stack does not necessarily have to appear in the stack_master.yml file.'
        c.example 'description', 'Delete a stack'
        c.action do |args, options|
          options.default config: default_config_file
          unless args.size == 2
            say "Invalid arguments. stack_master delete [region] [stack_name]"
            return
          end

          stack_name = Utils.underscore_to_hyphen(args[1])
          allowed_accounts = []

          # Because delete can work without a stack_master.yml
          if options.config and File.file?(options.config)
            config = load_config(options.config)
            region = Utils.underscore_to_hyphen(config.unalias_region(args[0]))
            allowed_accounts = config.find_stack(region, stack_name)&.allowed_accounts
          else
            region = args[0]
          end

          execute_if_allowed_account(allowed_accounts) do
            StackMaster.cloud_formation_driver.set_region(region)
            StackMaster::Commands::Delete.perform(region, stack_name)
          end
        end
      end

      run!
    end

    private

    def default_config_file
      "stack_master.yml"
    end

    def load_config(file)
      stack_file = file || default_config_file
      StackMaster::Config.load!(stack_file)
    rescue Errno::ENOENT => e
      say "Failed to load config file #{stack_file}"
      exit 1
    end

    def execute_stacks_command(command, args, options)
      success = true
      config = load_config(options.config)
      args = [nil, nil] if args.size == 0
      args.each_slice(2) do |aliased_region, stack_name|
        region = Utils.underscore_to_hyphen(config.unalias_region(aliased_region))
        stack_name = Utils.underscore_to_hyphen(stack_name)
        stack_definitions = config.filter(region, stack_name)
        if stack_definitions.empty?
          StackMaster.stdout.puts "Could not find stack definition #{stack_name} in region #{region}"
          success = false
        end
        stack_definitions = stack_definitions.select do |stack_definition|
          running_in_allowed_account?(stack_definition.allowed_accounts) && StackStatus.new(config, stack_definition).changed?
        end if options.changed
        stack_definitions.each do |stack_definition|
          StackMaster.cloud_formation_driver.set_region(stack_definition.region)
          StackMaster.stdout.puts "Executing #{command.command_name} on #{stack_definition.stack_name} in #{stack_definition.region}"
          success = execute_if_allowed_account(stack_definition.allowed_accounts) do
            command.perform(config, stack_definition, options).success?
          end
        end
      end
      success
    end

    def execute_if_allowed_account(allowed_accounts, &block)
      raise ArgumentError, "Block required to execute this method" unless block_given?
      if running_in_allowed_account?(allowed_accounts)
        block.call
      else
        StackMaster.stdout.puts "Account '#{identity.account}' is not an allowed account. Allowed accounts are #{allowed_accounts}."
        false
      end
    end

    def running_in_allowed_account?(allowed_accounts)
      identity.running_in_allowed_account?(allowed_accounts)
    end

    def identity
      @account ||= StackMaster::Identity.new
    end
  end
end
