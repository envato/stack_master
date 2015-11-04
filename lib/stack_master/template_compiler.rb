module StackMaster
  class TemplateCompiler
    def self.compile(template_file_path)
      if template_file_path.ends_with?('.rb')
        SparkleFormation.sparkle_path = File.dirname(template_file_path)
        JSON.pretty_generate(SparkleFormation.compile(template_file_path))
      else
        # Parse the json and rewrite compressed
        JSON.dump(JSON.parse(File.read(template_file_path)))
      end
    end
  end
end
