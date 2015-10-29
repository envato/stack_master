Given(/^I stub the following stack events:$/) do |table|
  table.hashes.each do |row|
    row.symbolize_keys!
    StackMaster.cloud_formation_driver.add_stack_event(row)
  end
end

Given(/^I stub the following stacks:$/) do |table|
  table.hashes.each do |row|
    row.symbolize_keys!
    params = row[:parameters].split(',').inject({}) do |hash, kv|
      key, value = kv.split('=')
      hash[key] = value
      hash
    end
    aws_params = StackMaster::Utils.hash_to_aws_parameters(params)
    row[:parameters] = aws_params
    StackMaster.cloud_formation_driver.add_stack(row)
  end
end

Given(/^I stub a template for the stack "([^"]*)":$/) do |stack_name, template_body|
  StackMaster.cloud_formation_driver.set_template(stack_name, template_body)
end
