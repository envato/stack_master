module StackMaster
  class Identity
    def running_in_allowed_account?(allowed_accounts)
      allowed_accounts.nil? ||
        allowed_accounts.empty? ||
        allowed_accounts.include?(account) ||
        contains_account_alias?(allowed_accounts)
    end

    def account
      @account ||= sts.get_caller_identity.account
    end

    def account_aliases
      @aliases ||= iam.list_account_aliases.account_aliases
    end

    private

    def region
      @region ||= ENV['AWS_REGION'] || Aws.config[:region] || Aws.shared_config.region || 'us-east-1'
    end

    def sts
      @sts ||= Aws::STS::Client.new(region: region)
    end

    def iam
      @iam ||= Aws::IAM::Client.new(region: region)
    end

    def contains_account_alias?(aliases)
      account_aliases.any? { |account_alias| aliases.include?(account_alias) }
    end
  end
end
