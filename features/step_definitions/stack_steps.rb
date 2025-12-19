Before do
  StackMaster.non_interactive_answer = 'y'
end

Given(/^I will answer prompts with "([^"]*)"$/) do |answer|
  StackMaster.non_interactive_answer = answer
end

Given(/^I stub the following stack events:$/) do |table|
  table.hashes.each do |row|
    row.symbolize_keys!
    StackMaster.cloud_formation_driver.add_stack_event(row)
  end
end

Given(/^I stub the following stack resources:$/) do |table|
  table.hashes.each do |row|
    row.symbolize_keys!
    StackMaster.cloud_formation_driver.add_stack_resource(row)
  end
end

def extract_hash_from_kv_string(string)
  string.to_s.split(',').each_with_object({}) do |kv, hash|
    key, value = kv.split('=')
    hash[key] = value
  end
end

Given(/^I stub the following stacks:$/) do |table|
  table.hashes.each do |row|
    row.symbolize_keys!
    row[:parameters] = StackMaster::Utils.hash_to_aws_parameters(extract_hash_from_kv_string(row[:parameters]))
    outputs = extract_hash_from_kv_string(row[:outputs]).each_with_object([]) do |(k, v), array|
      array << OpenStruct.new(output_key: k, output_value: v)
    end
    row[:outputs] = outputs
    StackMaster.cloud_formation_driver.add_stack(row)
  end
end

Given(/^I stub a template for the stack "([^"]*)":$/) do |stack_name, template_body|
  StackMaster.cloud_formation_driver.set_template(stack_name, template_body)
end

Then(/^the stack "([^"]*)" should have a policy with the following:$/) do |stack_name, policy|
  stack_policy_body = StackMaster.cloud_formation_driver.get_stack_policy(stack_name: stack_name).stack_policy_body
  expect(stack_policy_body).to eq policy
end

Then(/^the stack "([^"]*)" should contain this notification ARN "([^"]*)"$/) do |stack_name, notification_arn|
  stack = StackMaster.cloud_formation_driver.describe_stacks(stack_name: stack_name).stacks.first
  expect(stack).to be
  expect(stack.notification_arns).to include notification_arn
end

Given(/^I stub CloudFormation validate calls to pass validation$/) do
  allow(StackMaster.cloud_formation_driver).to receive(:validate_template).and_return(true)
end

Given(/^I stub CloudFormation validate calls to fail validation with message "([^"]*)"$/) do |message|
  allow(StackMaster.cloud_formation_driver)
    .to receive(:validate_template)
    .and_raise(Aws::CloudFormation::Errors::ValidationError.new('', message))
end

Given(/^I stub the CloudFormation driver$/) do
  allow(StackMaster.cloud_formation_driver.class).to receive(:new).and_return(StackMaster.cloud_formation_driver)
end

Then(/^an S3 file in bucket "([^"]*)" with key "([^"]*)" exists with content:$/) do |bucket, key, body|
  file = StackMaster.s3_driver.find_file(bucket: bucket, object_key: key)
  expect(file).to eq body
end

Then(/^an S3 file in bucket "([^"]*)" with key "([^"]*)" exists with JSON content:$/) do |bucket, key, body|
  file = StackMaster.s3_driver.find_file(bucket: bucket, object_key: key)
  parsed_file = JSON.parse(file)
  expect(parsed_file).to eq JSON.parse(body)
end
