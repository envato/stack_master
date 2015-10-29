module StackMaster
  class Validator
    include Command

    def initialize(stack_definition)
      @stack_definition = stack_definition
    end

    def perform
      template_body = TemplateCompiler.compile(@stack_definition.template_file_path)
      cf.validate_template(template_body: template_body)
      puts "Valid"
    rescue Aws::CloudFormation::Errors::ValidationError => e
      $stderr.puts "Validation Failed"
      $stderr.puts e.message
    end

    private

    def cf
      @cf ||= StackMaster.cloud_formation_driver
    end

  end
end
