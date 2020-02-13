module StackMaster
  class Identity
    def running_in_allowed_account?(allowed_accounts)
      allowed_accounts.nil? || allowed_accounts.empty? || allowed_accounts.include?(account)
    end

    def account
      @account ||= sts.get_caller_identity.account
    end

    private

    attr_reader :sts

    def profile
      @profile ||= ENV['AWS_PROFILE'] || 'default'
    end

    def region
      @region ||= ENV['AWS_REGION'] || Aws.config[:region] || Aws.shared_config.region || 'us-east-1'
    end

    def sts
      @sts ||= Aws::STS::Client.new(profile: profile, region: region)
    end
  end
end
