module StackMaster
  class Validator
    include Command

    def initialize(stack_definition)
      @stack_definition = stack_definition
    end

    def perform
      StackMaster.stdout.print "#{@stack_definition.stack_name}: "
      template_body = TemplateCompiler.compile(@stack_definition.template_file_path)
      cf.validate_template(template_body: template_body)
      StackMaster.stdout.puts "valid"
    rescue Aws::CloudFormation::Errors::ValidationError => e
      StackMaster.stdout.puts "invalid. #{e.message}"
      failed
    end

    private

    def cf
      @cf ||= StackMaster.cloud_formation_driver
    end

  end
end
