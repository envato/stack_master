Given(/^I stub the following stack events:$/) do |table|
  table.hashes.each do |row|
    row.symbolize_keys!
    StackMaster.cloud_formation_driver.add_stack_event(row)
  end
end

def extract_hash_from_kv_string(string)
  string.to_s.split(',').inject({}) do |hash, kv|
    key, value = kv.split('=')
    hash[key] = value
    hash
  end
end


Given(/^I stub the following stacks:$/) do |table|
  table.hashes.each do |row|
    row.symbolize_keys!
    row[:parameters] = StackMaster::Utils.hash_to_aws_parameters(extract_hash_from_kv_string(row[:parameters]))
    outputs = extract_hash_from_kv_string(row[:outputs]).inject([]) do |array, (k, v)|
      array << OpenStruct.new(output_key: k, output_value: v)
      array
    end
    row[:outputs] = outputs
    StackMaster.cloud_formation_driver.add_stack(row)
  end
end

Given(/^I stub a template for the stack "([^"]*)":$/) do |stack_name, template_body|
  StackMaster.cloud_formation_driver.set_template(stack_name, template_body)
end
