module StackMaster
  class TemplateCompiler
    def self.compile(template_file_path)
      if template_file_path.ends_with?('.rb')
        JSON.pretty_generate(SparkleFormation.compile(template_file_path))
      else
        File.read(template_file_path)
      end
    end
  end
end
