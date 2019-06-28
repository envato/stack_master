Given(/^I use the account "([^"]*)"$/) do |account_id|
  Aws.config[:sts] = {
    stub_responses: {
      get_caller_identity: {
        account: account_id,
        arn: 'an-arn',
        user_id: 'a-user-id'
      }
    }
  }
end
