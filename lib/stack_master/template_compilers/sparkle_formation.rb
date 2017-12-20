require 'stack_master/sparkle_formation/compile_time/parameters_validator'
require 'stack_master/sparkle_formation/compile_time/definitions_validator'
require 'stack_master/sparkle_formation/compile_time/state_builder'

module StackMaster::TemplateCompilers
  class SparkleFormation

    CompileTime = StackMaster::SparkleFormation::CompileTime

    def self.require_dependencies
      require 'sparkle_formation'
      require 'stack_master/sparkle_formation/template_file'
    end

    def self.compile(template_file_path, compile_time_parameters, compiler_options = {})
      if compiler_options['sparkle_path']
        ::SparkleFormation.sparkle_path = File.expand_path(compiler_options['sparkle_path'])
      else
        ::SparkleFormation.sparkle_path = File.dirname(template_file_path)
      end
      sparkle_template = ::SparkleFormation.compile(template_file_path, :sparkle)
      definitions = sparkle_template.parameters
      validate_definitions(definitions)
      validate_parameters(definitions, compile_time_parameters)

      sparkle_template.compile_time_parameter_setter do
        sparkle_template.compile_state = create_state(definitions, compile_time_parameters)
      end

      JSON.pretty_generate(sparkle_template)
    end

    private

    def self.validate_definitions(definitions)
      CompileTime::DefinitionsValidator.new(definitions).validate
    end

    def self.validate_parameters(definitions, compile_time_parameters)
      CompileTime::ParametersValidator.new(definitions, compile_time_parameters).validate
    end

    def self.create_state(definitions, compile_time_parameters)
      CompileTime::StateBuilder.new(definitions, compile_time_parameters).build
    end

    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end
