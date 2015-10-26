module StackMaster
  class Stack
    include Virtus.model

    attribute :stack_name, String
    attribute :region, String
    attribute :stack_id, String

    def self.find(region, stack_name)
      cf = Aws::CloudFormation::Client.new(region: region)
      cf_stack = cf.describe_stacks(stack_name: stack_name).stacks.first
      new(region: region, stack_name: stack_name, stack_id: cf_stack.stack_id)
    rescue Aws::CloudFormation::Errors::ValidationError
      nil
    end
  end
end
