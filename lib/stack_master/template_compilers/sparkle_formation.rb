require 'bogo'
require_relative '../sparkle_formation/parameter_validator'

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

      sf = ::SparkleFormation.compile(template_file_path, :sparkle)
      sf.compile_time_parameter_setter do |formation|
        current_state = {}
        unless (formation.parameters.empty?)
          formation.parameters.each do |k, v|
            current_value =  parameters[k.to_s.camelize]
            current_state[k] = request_compile_parameter(k, v,
                                                         current_value,
                                                         !!formation.parent
            )
            parameters.delete(k.to_s.camelize)
          end
          formation.compile_state = current_state
        end
      end
      JSON.pretty_generate(sf)
    end

    def self.request_compile_parameter(p_name, p_config, cur_val, nested=false)

      parameter_type = p_config.fetch(:type, 'string').to_s.downcase.to_sym
      if (parameter_type == :complex)
        if (cur_val.nil?)
          raise ArgumentError.new "No value provided for `#{p_name}` parameter (Complex data type)"
        else
          cur_val
        end
      else
        unless (cur_val || p_config[:default].nil?)
          cur_val = p_config[:default]
        end
        if (cur_val.is_a?(Array))
          cur_val = cur_val.map(&:to_s).join(',')
        end

        result = cur_val.to_s
        case parameter_type
          when :string
            if (p_config[:multiple])
              result = result.split(',').map(&:strip)
            end
          when :number
            if (p_config[:multiple])
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
            raise ArgumentError.new "Unknown compile time parameter type provided: `#{p_config[:type].inspect}` (Parameter: #{p_name})"
        end
        valid = StackMaster::SparkleFormation::ParameterValidator.validate_parameter(result, p_config.to_smash)
        unless valid == true
          error_message = valid.map {|parameter_error| "#{parameter_error[0]}: #{parameter_error[1]}" }.join("\n")
          raise ArgumentError.new "Invalid compile time parameters provided:\n#{error_message}"
        end
        result
      end
    end

    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end
