module StackMaster
  class Stack
    include Virtus.model

    attribute :stack_name, String
    attribute :region, String
    attribute :stack_id, String
    attribute :parameters, Array[Hash]
    attribute :template_body, String
    attribute :outputs, Array

    def template_hash
      @template_hash ||= JSON.parse(template_body)
    end

    def self.find(region, stack_name)
      cf = Aws::CloudFormation::Client.new(region: region)
      cf_stack = cf.describe_stacks(stack_name: stack_name).stacks.first
      parameters = cf_stack.parameters.inject({}) do |params_hash, param_struct|
        params_hash[param_struct.parameter_key] = param_struct.parameter_value
        params_hash
      end
      template_body ||= cf.get_template(stack_name: stack_name).template_body
      outputs = cf_stack.outputs

      new(region: region, stack_name: stack_name, stack_id: cf_stack.stack_id, parameters: parameters, template_body: template_body, outputs: outputs)
    rescue Aws::CloudFormation::Errors::ValidationError
      nil
    end
  end
end
