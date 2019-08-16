module StackMaster::TemplateCompilers
  class Yaml
    def self.require_dependencies
      require 'yaml'
      require 'json'
    end

    def self.compile(template_dir, template, _compile_time_parameters, _compiler_options = {})
      template_file_path = File.join(template_dir, template)
      File.read(template_file_path)
    end

    StackMaster::TemplateCompiler.register(:yaml, self)
  end
end
