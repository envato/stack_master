module StackMaster
  module Commands
    class Apply
      include Command
      include Commander::UI
      include StackMaster::Prompter
      TEMPLATE_TOO_LARGE_ERROR_MESSAGE = 'The (space compressed) stack is larger than the limit set by AWS. See http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html'.freeze

      def initialize(config, stack_definition, options = {})
        @config = config
        @s3_config = stack_definition.s3
        @stack_definition = stack_definition
        @from_time = Time.now
      end

      def perform
        diff_stacks
        ensure_valid_parameters!
        ensure_valid_template_body_size!
        create_or_update_stack
        tail_stack_events
      end

      private

      def cf
        @cf ||= StackMaster.cloud_formation_driver
      end

      def s3
        @s3 ||= StackMaster.s3_driver
      end

      def stack
        @stack ||= Stack.find(region, stack_name)
      end

      def proposed_stack
        @proposed_stack ||= Stack.generate(@stack_definition, @config)
      end

      def stack_exists?
        !stack.nil?
      end

      def use_s3?
        !@s3_config.empty?
      end

      def diff_stacks
        StackDiffer.new(proposed_stack, stack).output_diff
      end

      def create_or_update_stack
        if stack_exists?
          update_stack
        else
          create_stack
        end
      end

      def create_stack
        unless ask?('Create stack (y/n)? ')
          failed!("Stack creation aborted")
        end
        upload_files
        cf.create_stack(stack_options.merge(tags: proposed_stack.aws_tags))
      end

      def ask_to_cancel_stack_update
        if ask?("Cancel stack update?")
          StackMaster.stdout.puts "Attempting to cancel stack update"
          cf.cancel_update_stack(stack_name: stack_name)
          tail_stack_events
        end
      end

      def update_stack
        upload_files
        @change_set = ChangeSet.create(stack_options)
        halt!(@change_set.status_reason) if @change_set.failed?
        @change_set.display(StackMaster.stdout)
        unless ask?("Apply change set (y/n)? ")
          ChangeSet.delete(@change_set.id)
          halt! "Stack update aborted"
        end
        execute_change_set
      end

      def upload_files
        return unless use_s3?
        s3.upload_files(s3_options)
      end

      def template_method
        use_s3? ? :template_url : :template_body
      end

      def template_value
        if use_s3?
          s3.url(bucket: @s3_config['bucket'], prefix: @s3_config['prefix'], region: @s3_config['region'], template: @stack_definition.s3_template_file_name)
        else
          proposed_stack.maybe_compressed_template_body
        end
      end

      def files_to_upload
        return {} unless use_s3?
        @stack_definition.s3_files.tap do |files|
          files[@stack_definition.s3_template_file_name] = {
            path: @stack_definition.template_file_path,
            body: proposed_stack.maybe_compressed_template_body
          }
        end
      end

      def stack_options
        {
          stack_name: stack_name,
          parameters: proposed_stack.aws_parameters,
          capabilities: ['CAPABILITY_IAM'],
          notification_arns: proposed_stack.notification_arns,
          stack_policy_body: proposed_stack.stack_policy_body,
          template_method => template_value
        }
      end

      def s3_options
        {
          bucket: @s3_config['bucket'],
          prefix: @s3_config['prefix'],
          region: @s3_config['region'],
          files: files_to_upload
        }
      end

      def tail_stack_events
        StackEvents::Streamer.stream(stack_name, region, io: StackMaster.stdout, from: @from_time)
      rescue StackMaster::CtrlC
        ask_to_cancel_stack_update
      end

      def execute_change_set
        ChangeSet.execute(@change_set.id, stack_name)
      rescue StackMaster::CtrlC
        ask_to_cancel_stack_update
      end

      def ensure_valid_parameters!
        if @proposed_stack.missing_parameters?
          StackMaster.stderr.puts "Empty/blank parameters detected, ensure values exist for those parameters. Parameters will be read from the following locations:"
          @stack_definition.parameter_files.each do |parameter_file|
            StackMaster.stderr.puts " - #{parameter_file}"
          end
          halt!
        end
      end

      def ensure_valid_template_body_size!
        if proposed_stack.too_big?(use_s3?)
          failed! TEMPLATE_TOO_LARGE_ERROR_MESSAGE
        end
      end

      extend Forwardable
      def_delegators :@stack_definition, :stack_name, :region
    end
  end
end
