module StackMaster::TemplateCompilers
  class Json
    MAX_TEMPLATE_SIZE = 51200
    private_constant :MAX_TEMPLATE_SIZE

    def self.require_dependencies
      require 'json'
    end

    def self.compile(config, template_file_path, stack_definition)
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
