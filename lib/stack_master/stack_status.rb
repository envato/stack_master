module StackMaster
  class StackStatus
    def initialize(config, stack_definition)
      @config = config
      @stack_definition = stack_definition
    end

    def changed_message
      if changed?
        'Yes'
      elsif no_echo_params?
        'No *'
      else
        'No'
      end
    end

    def changed?
      stack.nil? || body_changed? || parameters_changed?
    end

    def status
      stack ? stack.stack_status : nil
    end

    def body_changed?
      stack.nil? || differ.body_different?
    end

    def parameters_changed?
      stack.nil? || differ.params_different?
    end

    def no_echo_params?
      !differ.noecho_keys.empty?
    end

    private

    def stack
      return @stack if defined?(@stack)
      StackMaster.cloud_formation_driver.set_region(stack_definition.region)
      @stack = find_stack
    end

    def find_stack
      Stack.find(stack_definition.region, stack_definition.raw_stack_name)
    rescue Aws::CloudFormation::Errors::ValidationError
    end

    def differ
      @differ ||= StackMaster::StackDiffer.new(proposed_stack, stack)
    end

    def proposed_stack
      @proposed_stack ||= Stack.generate(stack_definition, @config)
    end

    attr_reader :stack_definition
  end
end
