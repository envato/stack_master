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
      template_body = Stack.generate(@stack_definition, @config).maybe_compressed_template_body
      cf.validate_template(template_body: template_body)
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

  end
end
