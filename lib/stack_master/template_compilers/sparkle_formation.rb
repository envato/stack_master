require_relative '../sparkle_formation/compile_time/parameters_validator'
require_relative '../sparkle_formation/compile_time/definitions_validator'
require_relative '../sparkle_formation/compile_time/state_builder'

module StackMaster::TemplateCompilers
  class SparkleFormation

    CompileTime = StackMaster::SparkleFormation::CompileTime

    def self.require_dependencies
      require 'sparkle_formation'
      require 'stack_master/sparkle_formation/template_file'
    end

    def self.compile(template_file_path, parameters, compiler_options = {})
      if compiler_options['sparkle_path']
        ::SparkleFormation.sparkle_path = File.expand_path(compiler_options['sparkle_path'])
      else
        ::SparkleFormation.sparkle_path = File.dirname(template_file_path)
      end
      sparkle_template = ::SparkleFormation.compile(template_file_path, :sparkle)
      definitions = sparkle_template.parameters
      validate_definitions(definitions)
      validate_parameters(definitions, parameters)

      sparkle_template.compile_time_parameter_setter do
        sparkle_template.compile_state = create_state(definitions, parameters)
        remove_compile_parameters(definitions, parameters)
      end

      JSON.pretty_generate(sparkle_template)
    end

    private

    def self.validate_definitions(definitions)
      CompileTime::DefinitionsValidator.new(definitions).validate
    end

    def self.validate_parameter(name, definition, parameter)
      CompileTime::ParameterValidator.new(name, definition, parameter).validate
    end

    def self.validate_parameters(definitions, parameters)
      CompileTime::ParametersValidator.new(definitions, parameters).validate
    end

    def self.create_state(definitions, parameters)
      CompileTime::StateBuilder.new(definitions, parameters).build
    end

    def self.remove_compile_parameters(definitions, parameters)
      definitions.each {|name, _definition| parameters.delete(name.to_s.camelize)}
    end

    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end
