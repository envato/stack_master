Then(/^I expect the role "([^"]*)" is assumed in account "([^"]*)"$/) do |role, account|
  expect(Aws::AssumeRoleCredentials).to receive(:new).with(
    role_arn: "arn:aws:iam::#{account}:role/#{role}",
    role_session_name: instance_of(String)
  )
end
