module StackMaster
  module TestDriver
    class Stack
      attr_reader :stack_id,
                  :stack_name,
                  :description,
                  :parameters,
                  :creation_time,
                  :last_update_time,
                  :stack_status,
                  :stack_status_reason,
                  :disable_rollback,
                  :role_arn,
                  :notification_arns,
                  :timeout_in_minutes,
                  :capabilities,
                  :outputs,
                  :tags

      include Utils::Initializable

      def parameters
        @parameters.map do |hash|
          OpenStruct.new(parameter_key: hash[:parameter_key],
                         parameter_value: hash[:parameter_value])
        end
      end
    end

    class StackEvent
      attr_reader :stack_id,
                  :event_id,
                  :stack_name,
                  :logical_resource_id,
                  :physical_resource_id,
                  :resource_type,
                  :timestamp,
                  :resource_status,
                  :resource_status_reason,
                  :resource_properties

      include Utils::Initializable

      def timestamp
        Time.parse(@timestamp) if @timestamp
      end
    end

    class StackResource
      attr_reader :stack_name,
                  :stack_id,
                  :logical_resource_id,
                  :physical_resource_id,
                  :resource_type,
                  :timestamp,
                  :resource_status,
                  :resource_status_reason,
                  :description

      include Utils::Initializable
    end

    class CloudFormation
      def initialize
        reset
      end

      def region
        @region ||= ENV['AWS_REGION'] || Aws.config[:region] || Aws.shared_config.region
      end

      def set_region(region)
        @region = region
      end

      def reset
        @stacks = {}
        @templates = {}
        @stack_events = {}
        @stack_resources = {}
        @stack_policies = {}
        @change_sets = {}
      end

      def create_change_set(options)
        id = SecureRandom.uuid
        options.merge!(change_set_id: id)
        @change_sets[id] = options
        @change_sets[options.fetch(:change_set_name)] = options
        OpenStruct.new(id: id)
      end

      def describe_change_set(options)
        change_set_id = options.fetch(:change_set_name)
        change_set = @change_sets.fetch(change_set_id)
        change_details = [
          OpenStruct.new(evaluation: 'Static', change_source: 'ResourceReference', target: OpenStruct.new(attribute: 'Properties', requires_recreation: 'Always', name: 'blah'))
        ]
        change = OpenStruct.new(action: 'Modify', replacement: 'True', scope: ['Properties'], details: change_details)
        changes = [
          OpenStruct.new(type: 'AWS::Resource', resource_change: change)
        ]
        OpenStruct.new(change_set.merge(changes: changes, status: 'CREATE_COMPLETE'))
      end

      def execute_change_set(options)
        change_set_id = options.fetch(:change_set_name)
        change_set = @change_sets.fetch(change_set_id)
        update_stack(change_set)
      end

      def delete_change_set(options)
        change_set_id = options.fetch(:change_set_name)
        @change_sets.delete(change_set_id)
      end

      def describe_stacks(options = {})
        stack_name = options[:stack_name]
        stacks = if stack_name
          if @stacks[stack_name]
            [@stacks[stack_name]]
          else
            raise Aws::CloudFormation::Errors::ValidationError.new('', 'Stack does not exist')
          end
        else
          @stacks.values
        end
        OpenStruct.new(stacks: stacks, next_token: nil)
      end

      def describe_stack_resources(options = {})
        @stacks.fetch(options.fetch(:stack_name)) { raise Aws::CloudFormation::Errors::ValidationError.new('', 'Stack does not exist') }
        OpenStruct.new(stack_resources: @stack_resources[options.fetch(:stack_name)])
      end

      def get_template(options)
        template_body = @templates[options[:stack_name]] || nil
        OpenStruct.new(template_body: template_body)
      end

      def get_stack_policy(options)
        OpenStruct.new(stack_policy_body: @stack_policies[options.fetch(:stack_name)])
      end

      def describe_stack_events(options)
        events = @stack_events[options.fetch(:stack_name)] || []
        OpenStruct.new(stack_events: events, next_token: nil)
      end

      def update_stack(options)
        stack_name = options.fetch(:stack_name)
        @stacks[stack_name].attributes = options
        @stack_policies[stack_name] = options[:stack_policy_body]
      end

      def create_stack(options)
        stack_name = options.fetch(:stack_name)
        add_stack(options)
        @stack_policies[stack_name] = options[:stack_policy_body]
      end

      def delete_stack(options)
        stack_name = options.fetch(:stack_name)
        @stacks.delete(stack_name)
      end

      def validate_template(options)
        true
      end

      def add_stack(stack)
        @stacks[stack.fetch(:stack_name)] = Stack.new(stack)
      end

      def add_stack_resource(options)
        @stack_resources[options.fetch(:stack_name)] ||= []
        @stack_resources[options.fetch(:stack_name)] << StackResource.new(options)
      end

      def set_template(stack_name, template)
        @templates[stack_name] = template
      end

      def add_stack_event(event)
        stack_name = event.fetch(:stack_name)
        @stack_events[stack_name] ||= []
        @stack_events[stack_name] << StackEvent.new(event)
      end
    end
  end
end
