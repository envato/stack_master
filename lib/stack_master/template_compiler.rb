module StackMaster
  class TemplateCompiler

    MAX_TEMPLATE_SIZE = 51200

    def self.compile(template_file_path)
      if template_file_path.ends_with?('.rb')
        SparkleFormation.sparkle_path = File.dirname(template_file_path)
        JSON.pretty_generate(SparkleFormation.compile(template_file_path))
      else
        template_body = File.read(template_file_path)
        if template_body.size > MAX_TEMPLATE_SIZE
          # Parse the json and rewrite compressed
          JSON.dump(JSON.parse(template_body))
        else
          template_body
        end
      end
    end
  end
end
