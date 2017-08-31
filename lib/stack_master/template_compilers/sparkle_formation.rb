module StackMaster::TemplateCompilers
  class SparkleFormation
    def self.require_dependencies
      require 'sparkle_formation'
      require 'stack_master/sparkle_formation/template_file'
    end

    def self.compile(template_file_path, _parameters, compiler_options = {})
      if compiler_options["sparkle_path"]
        ::SparkleFormation.sparkle_path = File.expand_path(compiler_options["sparkle_path"])
      else
        ::SparkleFormation.sparkle_path = File.dirname(template_file_path)
      end

      sf = ::SparkleFormation.compile(template_file_path, :sparkle)
      sf.compile_time_parameter_setter do |formation|
        current_state = {}
        unless(formation.parameters.empty?)
          formation.parameters.each do |k,v|
            current_value = _parameters[k.to_s.camelize]
            current_state[k] = request_compile_parameter(k, v,
                                                         current_value,
                                                         !!formation.parent
            )
          end
          formation.compile_state = current_state
        end
      end

      # args ={ state: _parameters}
      # sparkle_formation = ::SparkleFormation.compile(template_file_path, args)
      #sparkle_formation = ::SparkleFormation.compile(template_file_path)
      JSON.pretty_generate(sf)
    end

    # Request compile time parameter value
    #
    # @param p_name [String, Symbol] name of parameter
    # @param p_config [Hash] parameter meta information
    # @param cur_val [Object, NilClass] current value assigned to parameter
    # @param nested [TrueClass, FalseClass] template is nested
    # @option p_config [String, Symbol] :type
    # @option p_config [String, Symbol] :default
    # @option p_config [String, Symbol] :description
    # @option p_config [String, Symbol] :multiple
    # @return [Object]
    def self.request_compile_parameter(p_name, p_config, cur_val, nested=false)
      result = nil
      attempts = 0
      parameter_type = p_config.fetch(:type, 'string').to_s.downcase.to_sym
      if(parameter_type == :complex)
        if(cur_val.nil?)
          raise ArgumentError.new "No value provided for `#{p_name}` parameter (Complex data type)"
        else
          cur_val
        end
      else
        unless(cur_val || p_config[:default].nil?)
          cur_val = p_config[:default]
        end
        if(cur_val.is_a?(Array))
          cur_val = cur_val.map(&:to_s).join(',')
        end
        until(result && (!result.respond_to?(:empty?) || !result.empty?))
          attempts += 1
          result = cur_val.to_s
          case parameter_type
            when :string
              if(p_config[:multiple])
                result = result.split(',').map(&:strip)
              end
            when :number
              if(p_config[:multiple])
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
        end
        result
      end
    end
    StackMaster::TemplateCompiler.register(:sparkle_formation, self)
  end
end
