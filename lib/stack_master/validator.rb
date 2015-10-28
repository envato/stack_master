module StackMaster
  class Validator
    include Command

    def initialize(stack_definition)
      @stack_definition = stack_definition
    end

    def perform
      cf.validate_template(template_body: @stack_definition.template_body)
      puts "Valid"
    rescue Aws::CloudFormation::Errors::ValidationError => e
      $stderr.puts "Validation Failed"
      $stderr.puts e.message
    end

    private

    def cf
      @cf ||= Aws::CloudFormation::Client.new(region: @stack_definition.region)
    end

  end
end
