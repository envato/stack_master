module StackMaster::TemplateCompilers
  class Yaml
    def self.require_dependencies
      require 'yaml'
      require 'json'
    end

    def self.compile(_template_dir, template_file_path, _sparkle_pack_template, _compile_time_parameters, _compiler_options = {})
      File.read(template_file_path)
    end

    StackMaster::TemplateCompiler.register(:yaml, self)
  end
end
