module StackMaster::TemplateCompilers
  class Yaml
    def self.require_dependencies
      require 'yaml'
      require 'json'
    end

    def self.compile(config, template_file_path, stack_definition)
      File.read(template_file_path)
    end

    StackMaster::TemplateCompiler.register(:yaml, self)
  end
end
