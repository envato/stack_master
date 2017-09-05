require_relative '../sparkle_formation/compile_time/parameter_builder'
require_relative '../sparkle_formation/compile_time/parameter_validator'
require_relative '../sparkle_formation/compile_time/definition_validator'
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
      template = ::SparkleFormation.compile(template_file_path, :sparkle)
      template.compile_time_parameter_setter do |formation|
        state  = CompileTime::StateBuilder.new(formation, parameters).build
        state.each do |name, compile_parameter|
          definition = formation.parameters[name]
          validate_definition(name, definition)
          validate_parameter(name, definition, compile_parameter)
          parameters.delete(name.to_s.camelize)
        end
        formation.compile_state = state
      end
      JSON.pretty_generate(template)
    end

    private

    def self.validate_definition(name, definition)
      validator = CompileTime::DefinitionValidator.new(name, definition)
      validator.validate
      raise ArgumentError.new "Unknown compile time parameter type: #{validator.error}" unless validator.is_valid
    end

    def self.validate_parameter(name, definition, parameter)
      validator = CompileTime::ParameterValidator.new(name, definition, parameter)
      validator.validate
      raise ArgumentError.new "Invalid compile time parameter: #{validator.error}" unless validator.is_valid
    end

    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end
