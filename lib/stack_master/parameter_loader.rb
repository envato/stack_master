module StackMaster
  class ParameterLoader
    def self.load(parameter_files)
      parameter_files.reduce({}) do |hash, file_name|
        parameters = if File.exists?(file_name)
          YAML.load(File.read(file_name))
        else
          {}
        end
        hash.merge(parameters)
      end
    end
  end
end
