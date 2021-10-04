module StackMaster
  class Identity
    AllowedAccountAliasesError = Class.new(StandardError)
    MissingIamPermissionsError = Class.new(StandardError)

    def running_in_account?(accounts)
      return true if accounts.nil? || accounts.empty? || contains_account_id?(accounts)

      # skip alias check (which makes an API call) if all values are account IDs
      return false if accounts.all? { |account| account_id?(account) }

      contains_account_alias?(accounts)
    rescue MissingIamPermissionsError
      raise AllowedAccountAliasesError, "Unable to validate whether the current AWS account is allowed"
    end

    def account
      @account ||= sts.get_caller_identity.account
    end

    def account_aliases
      @aliases ||= iam.list_account_aliases.account_aliases
    rescue Aws::IAM::Errors::AccessDenied
      raise MissingIamPermissionsError, 'Failed to retrieve account aliases. Missing required IAM permission: iam:ListAccountAliases'
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

    def contains_account_id?(ids)
      ids.include?(account)
    end

    def contains_account_alias?(aliases)
      return false if aliases.empty?

      account_aliases.any? { |account_alias| aliases.include?(account_alias) }
    end

    def account_id?(id_or_alias)
      # While it's not explicitly documented as prohibited, it cannot (currently) be possible to set an account alias of
      # 12 digits, as that could cause one console sign-in URL to resolve to two separate accounts.
      /^[0-9]{12}$/.match?(id_or_alias)
    end
  end
end
