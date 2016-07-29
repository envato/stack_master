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
        parameters = ParameterLoader.load(stack.parameter_files)
        any_stack_output_outdated?(parameters, dependent_stack)
      end
    end

    private

    def any_stack_output_outdated?(params, stack)
      params.any? do |key, value|
        stack_output_outdated?(value['stack_output'], stack, @stack_definition.stack_name) ||
          stack_outputs_outdated?(value['stack_outputs'], stack, @stack_definition.stack_name, key)
      end
    end

    def stack_output_outdated?(stack_output, stack, stack_name)
      stack_output &&
        stack_output_is_our_stack?(stack_output, stack_name) &&
        outdated?(stack, stack_output.split('/').last)
    end

    def stack_outputs_outdated?(stack_outputs, stack, stack_name, parameter_key)
      dependent_parameter = stack_parameter(stack, parameter_key)
      stack_outputs && stack_outputs.any? do |output|
        index = stack_outputs.find_index(output)
        this_output_value = dependent_parameter.split(',')[index]
        stack_output_is_our_stack?(output, stack_name) &&
          output_value(output.split('/').last.camelize) != this_output_value
      end
    end

    def stack_output_is_our_stack?(stack_output, stack)
      stack_output.gsub('_', '-') =~ %r(#{stack}/)
    end

    def outdated?(dependent_stack, output_key)
      stack_output = output_value(output_key.camelize)
      dependent_input = stack_parameter(dependent_stack, output_key)
      dependent_input != stack_output
    end

    def stack_parameter(stack, key)
      stack.parameters[key.camelize]
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
