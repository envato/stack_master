module StackMaster
  class ParameterLoader
    def self.load(parameter_files)
      parameter_files.reduce({}) do |hash, file_name|
        parameters = if File.exists?(file_name)
          YAML.load(File.read(file_name)) || {}
        else
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
