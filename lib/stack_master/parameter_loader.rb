module StackMaster
  class ParameterLoader
    def self.load(parameter_files)
      StackMaster.debug "Searching for parameter files..."
      parameter_files.reduce({}) do |hash, file_name|
        parameters = if File.exists?(file_name)
         StackMaster.debug "  #{file_name} found"
          YAML.load(File.read(file_name)) || {}
        else
         StackMaster.debug "  #{file_name} not found"
          {}
        end
        parameters.each do |key, value|
          hash[key.camelize] = value
        end
        hash
      end
    end
  end
end
