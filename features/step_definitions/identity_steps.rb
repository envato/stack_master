Given(/^I use the account "([^"]*)"(?: with alias "([^"]*)")?$/) do |account_id, account_alias|
  Aws.config[:sts] = {
    stub_responses: {
      get_caller_identity: {
        account: account_id,
        arn: 'an-arn',
        user_id: 'a-user-id'
      }
    }
  }

  if account_alias.present?
    Aws.config[:iam] = {
      stub_responses: {
        list_account_aliases: {
          account_aliases: [account_alias],
          is_truncated: false
        }
      }
    }
  else
    # ensure stubs don't leak between steps
    Aws.config[:iam]&.delete(:stub_responses)
  end
end
