module StackMaster
  module TestDriver
    class Stack
      include Virtus.model
      attribute :stack_id, String
      attribute :stack_name, String
      attribute :description, String
      attribute :parameters, Array[OpenStruct]
      attribute :creation_time, String
      attribute :last_update_time, String
      attribute :stack_status, String
      attribute :stack_status_reason, String
      attribute :disable_rollback, String
      attribute :notification_arns, Array
      attribute :timeout_in_minutes, Integer
      attribute :capabilities, Array
      attribute :outputs, Array[OpenStruct]
      attribute :tags, Array[OpenStruct]
    end

    class StackEvent
      include Virtus.model
      attribute :stack_id, String
      attribute :event_id, String
      attribute :stack_name, String
      attribute :logical_resource_id, String
      attribute :physical_resource_id, String
      attribute :resource_type, String
      attribute :timestamp, Time
      attribute :resource_status, String
      attribute :resource_status_reason, String
      attribute :resource_properties, String
    end

    class StackResource
      include Virtus.model
      attribute :stack_name, String
      attribute :stack_id, String
      attribute :logical_resource_id, String
      attribute :physical_resource_id, String
      attribute :resource_type, String
      attribute :timestamp, Time
      attribute :resource_status, String
      attribute :resource_status_reason, String
      attribute :description, String
    end

    class CloudFormation
      def initialize
        reset
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
