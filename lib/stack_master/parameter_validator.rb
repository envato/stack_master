require 'pathname'

module StackMaster
  class ParameterValidator
    def initialize(stack:, stack_definition:)
      @stack = stack
      @stack_definition = stack_definition
    end

    def error_message
      return nil unless missing_parameters?
      message = "Empty/blank parameters detected. Please provide values for these parameters:\n"
      missing_parameters.each do |parameter_name|
        message << " - #{parameter_name}\n"
      end
      if @stack_definition.parameter_files.empty?
        message << message_for_parameter_globs
      else
        message << message_for_parameter_files
      end
      message
    end

    def missing_parameters?
      missing_parameters.any?
    end

    private

    def message_for_parameter_files
      "Parameters are configured to be read from the following files:\n".tap do |message|
        @stack_definition.parameter_files.each do |parameter_file|
          message << " - #{parameter_file}\n"
        end
      end
    end

    def message_for_parameter_globs
      "Parameters will be read from files matching the following globs:\n".tap do |message|
        base_dir = Pathname.new(@stack_definition.base_dir)
        @stack_definition.parameter_file_globs.each do |glob|
          parameter_file = Pathname.new(glob).relative_path_from(base_dir)
          message << " - #{parameter_file}\n"
        end
      end
    end

    def missing_parameters
      @missing_parameters ||=
        @stack.parameters_with_defaults.select { |_key, value| value.nil? }.keys
    end
  end
end
