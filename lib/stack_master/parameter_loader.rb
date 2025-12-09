require 'active_support/core_ext/object/deep_dup'

module StackMaster
  class ParameterLoader
    COMPILE_TIME_PARAMETERS_KEY = 'compile_time_parameters'

    def self.load(parameter_files: [], parameters: {})
      StackMaster.debug 'Searching for parameter files...'
      all_parameters = parameter_files.map { |file_name| load_parameters(file_name) } + [parameters]
      all_parameters.reduce({ template_parameters: {}, compile_time_parameters: {} }) do |hash, parameters|
        template_parameters = create_template_parameters(parameters)
        compile_time_parameters = create_compile_time_parameters(parameters)

        merge_and_camelize(hash[:template_parameters], template_parameters)
        merge_and_camelize(hash[:compile_time_parameters], compile_time_parameters)
        hash
      end
    end

    private

    def self.load_parameters(file_name)
      file_exists = File.exist?(file_name)
      StackMaster.debug file_exists ? "  #{file_name} found" : "  #{file_name} not found"
      file_exists ? load_file(file_name) : {}
    end

    def self.load_file(file_name)
      YAML.load(File.read(file_name)) || {}
    end

    def self.create_template_parameters(parameters)
      parameters.deep_dup.tap do |parameters_clone|
        parameters_clone.delete(COMPILE_TIME_PARAMETERS_KEY) ||
          parameters_clone.delete(COMPILE_TIME_PARAMETERS_KEY.camelize)
      end
    end

    def self.create_compile_time_parameters(parameters)
      (parameters[COMPILE_TIME_PARAMETERS_KEY] || parameters[COMPILE_TIME_PARAMETERS_KEY.camelize] || {}).deep_dup
    end

    def self.merge_and_camelize(hash, parameters)
      parameters.each { |key, value| hash[key.camelize] = value }
    end
  end
end
