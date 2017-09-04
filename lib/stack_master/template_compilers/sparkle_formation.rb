require_relative '../sparkle_formation/compile_time_parameter/parameter_validator'

module StackMaster::TemplateCompilers
  class SparkleFormation

    def self.require_dependencies
      require 'sparkle_formation'
      require 'stack_master/sparkle_formation/template_file'
    end

    def self.compile(template_file_path, parameters, compiler_options = {})
      if compiler_options["sparkle_path"]
        ::SparkleFormation.sparkle_path = File.expand_path(compiler_options["sparkle_path"])
      else
        ::SparkleFormation.sparkle_path = File.dirname(template_file_path)
      end

      template = ::SparkleFormation.compile(template_file_path, :sparkle)
      template.compile_time_parameter_setter do |formation|
        current_state = {}
        unless (formation.parameters.empty?)
          formation.parameters.each do |name, definition|
            parameter = parameters[name.to_s.camelize]
            current_state[name] = request_compile_parameter(name, definition, parameter)
            parameters.delete(name.to_s.camelize)
          end
          formation.compile_state = current_state
        end
      end
      JSON.pretty_generate(template)
    end

    def self.request_compile_parameter(name, definition, parameter)

      parameter_type = definition.fetch(:type, 'string').to_s.downcase.to_sym
      if parameter_type == :complex
        if parameter.nil?
          raise ArgumentError.new "No value provided for `#{name}` parameter (Complex data type)"
        else
          parameter
        end
      else
        unless parameter || definition[:default].nil?
          parameter = definition[:default]
        end
        if parameter.is_a?(Array)
          parameter = parameter.map(&:to_s).join(',')
        end

        result = parameter.to_s
        case parameter_type
          when :string
            if definition[:multiple]
              result = result.split(',').map(&:strip)
            end
          when :number
            if definition[:multiple]
              result = result.split(',').map(&:strip)
              new_result = result.map do |item|
                new_item = item.to_i
                new_item if new_item.to_s == item
              end
              result = new_result.size == result.size ? new_result : []
            else
              new_result = result.to_i
              result = new_result.to_s == result ? new_result : nil
            end
          else
            raise ArgumentError.new "Unknown compile time parameter type provided: `#{definition[:type].inspect}` (Parameter: #{name})"
        end

        parameter_validator = StackMaster::SparkleFormation::CompileTimeParameter::ParameterValidator.new(name, definition, result)
        parameter_validator.validate
        unless parameter_validator.is_valid
          raise ArgumentError.new "Invalid compile time parameter: #{parameter_validator.error}"
        end

        puts '-------'
        puts result
        puts '-------'

        result
      end
    end

    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end
