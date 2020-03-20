module StackMaster
  class Validator
    def self.valid?(stack_definition, config)
      new(stack_definition, config).perform
    end

    def initialize(stack_definition, config)
      @stack_definition = stack_definition
      @config = config
    end

    def perform
      StackMaster.stdout.print "#{@stack_definition.stack_name}: "
      cf.validate_template(template_body: TemplateUtils.maybe_compressed_template_body(stack.template_body))
      StackMaster.stdout.puts "valid"
      true
    rescue Aws::CloudFormation::Errors::ValidationError => e
      StackMaster.stdout.puts "invalid. #{e.message}"
      false
    end

    private

    def cf
      @cf ||= StackMaster.cloud_formation_driver
    end

    def stack
      @stack ||= Stack.generate(@stack_definition, @config)
    end
  end
end
