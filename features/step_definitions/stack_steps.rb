Given(/^I stub stack events:$/) do |table|
  table.hashes.each do |row|
    row.symbolize_keys!
    StackMaster.cloud_formation_driver.add_stack_event(row)
  end
end
