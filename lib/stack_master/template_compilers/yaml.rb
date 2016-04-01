module StackMaster::TemplateCompilers
  class Yaml

    def self.compile(template_file_path)
      template_body = File.read(template_file_path)

      begin
        JSON.dump(YAML.load(template_body))
      rescue Psych::Exception
        raise StackMaster::TemplateCompilers::Yaml::CompileError
      end
    end

    StackMaster::TemplateCompiler.register(:yaml, self)
    StackMaster::TemplateCompiler.register(:yml, self)

    class StackMaster::TemplateCompilers::Yaml::CompileError < RuntimeError; end
  end
end