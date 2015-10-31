require 'commander'

module StackMaster
  class CLI
    include Commander::Methods

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
      Commander::Runner.instance_variable_set('@singleton', Commander::Runner.new(argv))
      StackMaster.stdout = @stdout
      StackMaster.stderr = @stderr
    end

    def execute!
      program :name, 'StackMaster'
      program :version, '0.0.1'
      program :description, 'AWS Stack Management'

      global_option '-c', '--config FILE', 'Config file to use'

      default_command :list

      command :apply do |c|
        c.syntax = 'stack_master apply [region] [stack_name]'
        c.summary = ''
        c.description = ''
        c.example 'description', 'Create or update a stack'
        c.action do |args, options|
          execute_stack_command(StackMaster::Commands::Apply, args, options)
        end
      end

      command :init do |c|
        c.syntax = 'stack_master init [region] [stack_name]'
        c.summary = ''
        c.description = ''
        c.option('--overwrite', 'Overwrite existing files')
        c.action do |args, options|
          unless args.size == 2
            say "Invalid arguments. stack_master init [region] [stack_name]"
          else
            StackMaster::Commands::Init.perform(options.overwrite, *args)
          end
        end
      end

      command :diff do |c|
        c.syntax = 'stack_master diff [region] [stack_name]'
        c.summary = ''
        c.description = ''
        c.example 'description', 'Diff a stack'
        c.action do |args, options|
          execute_stack_command(StackMaster::Commands::Diff, args, options)
        end
      end

      command :list do |c|
        c.syntax = 'stack_master list'
        c.summary = ''
        c.description = ''
        c.example 'description', 'List of all stacks'
        c.action do |args, options|
          say "Invalid arguments." if args.size > 0
          config = load_config(options.config)
          StackMaster::Commands::ListStacks.perform(config)
        end
      end

      command :validate do |c|
        c.syntax = 'stack_master validate [region] [stack_name]'
        c.summary = ''
        c.description = ''
        c.example 'description', 'Validate a stack'
        c.action do |args, options|
          execute_stack_command(StackMaster::Commands::Validate, args, options)
        end
      end

      run!
    end

    def load_config(file)
      stack_file = file || 'stack_master.yml'
      StackMaster::Config.load!(stack_file)
    rescue Errno::ENOENT => e
      say "Failed to load config file #{stack_file}"
      exit 1
    end

    def execute_stack_command(command, args, options)
      say "Invalid arguments. stack_master #{command.name.split('::').last.downcase} [region] [stack_name]" and return unless args.size == 2
      config = load_config(options.config)
      aliased_region, stack_name = args
      region = Utils.underscore_to_hyphen(config.unalias_region(aliased_region))
      stack_name = Utils.underscore_to_hyphen(stack_name)
      StackMaster.cloud_formation_driver.set_region(region)
      command.perform(config, region, stack_name)
    end
  end
end
