module StackMaster::TemplateCompilers
  class Json
    MAX_TEMPLATE_SIZE = 51_200
    private_constant :MAX_TEMPLATE_SIZE

    def self.require_dependencies
      require 'json'
    end

    def self.compile(template_dir, template, _compile_time_parameters, _compiler_options = {})
      template_file_path = File.join(template_dir, template)
      template_body = File.read(template_file_path)
      if template_body.size > MAX_TEMPLATE_SIZE
        # Parse the json and rewrite compressed
        JSON.dump(JSON.parse(template_body))
      else
        template_body
      end
    end

    StackMaster::TemplateCompiler.register(:json, self)
  end
end
