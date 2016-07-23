module StackMaster
  class StackDependency
    StackOutputNotFound = Class.new(StandardError)

    def initialize(stack_definition, config)
      @stack_definition = stack_definition
      @config = config
    end

    def outdated_stacks
      @config.stacks.select do |stack|
        dependent_stack = Stack.find(stack.region, stack.stack_name)
        next unless dependent_stack
        ParameterLoader.load(stack.parameter_files).any? do |_, value|
          value['stack_output'] &&
            value['stack_output'].gsub('_', '-') =~ %r(#{@stack_definition.stack_name}/) &&
            outdated?(dependent_stack, value['stack_output'].split('/').last)
        end
      end
    end

    private

    def outdated?(dependent_stack, output_key)
      stack_output = output_value(output_key.camelize)
      dependent_input = dependent_stack.parameters[output_key.camelize]
      dependent_input != stack_output
    end

    def output_value(key)
      output_hash = updated_stack.outputs.select { |output_type| output_type[:output_key] == key }
      if output_hash && ! output_hash.empty?
        output_hash.first[:output_value]
      else
        raise StackOutputNotFound, "Stack exists (#{updated_stack.stack_name}), but output does not: #{key}"
      end
    end

    def updated_stack
      @stack ||= Stack.find(@stack_definition.region, @stack_definition.stack_name)
    end
  end
end