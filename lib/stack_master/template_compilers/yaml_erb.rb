# frozen_string_literal: true

module StackMaster::TemplateCompilers
  class YamlErb
    def self.require_dependencies
      require 'erubis'
      require 'yaml'
    end

    def self.compile(template_dir, template, compile_time_parameters, _compiler_options = {})
      template_file_path = File.join(template_dir, template)
      template = Erubis::Eruby.new(File.read(template_file_path))
      template.filename = template_file_path

      template.result(params: compile_time_parameters)
    end

    StackMaster::TemplateCompiler.register(:yaml_erb, self)
  end
end
