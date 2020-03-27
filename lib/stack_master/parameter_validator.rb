require 'pathname'

module StackMaster
  class ParameterValidator
    def initialize(stack:, stack_definition:)
      @stack = stack
      @stack_definition = stack_definition
    end

    def error_message
      return nil unless missing_parameters?
      message = "Empty/blank parameters detected. Please provide values for these parameters:"
      missing_parameters.each do |parameter_name|
        message << "\n - #{parameter_name}"
      end
      message << "\nParameters will be read from files matching the following globs:"
      base_dir = Pathname.new(@stack_definition.base_dir)
      @stack_definition.parameter_file_globs.each do |glob|
        parameter_file = Pathname.new(glob).relative_path_from(base_dir)
        message << "\n - #{parameter_file}"
      end
      message
    end

    def missing_parameters?
      missing_parameters.any?
    end

    private

    def missing_parameters
      @missing_parameters ||=
        @stack.parameters_with_defaults.select { |_key, value| value.nil? }.keys
    end
  end
end
