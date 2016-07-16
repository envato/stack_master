module StackMaster::TemplateCompilers
  class Yaml
    def self.require_dependencies
      require 'yaml'
      require 'json'
    end

    def self.compile(template_file_path)
      template_body = File.read(template_file_path)
      JSON.dump(YAML.load(template_body))
    end

    StackMaster::TemplateCompiler.register(:yaml, self)
  end
end