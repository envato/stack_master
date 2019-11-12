require 'active_support/core_ext/object/deep_dup'

module StackMaster
  class RoleAssumer
    BlockNotSpecified = Class.new(StandardError)

    def initialize
      @credentials = {}
    end

    def assume_role(account, role, &block)
      raise BlockNotSpecified unless block_given?
      raise ArgumentError, "Both 'account' and 'role' are required to assume a role" if account.nil? || role.nil?

      original_aws_config = replace_aws_global_config
      Aws.config[:credentials] = assume_role_credentials(account, role)
      begin
        original_cf_driver = replace_cf_driver
        block.call
      ensure
        restore_aws_global_config(original_aws_config)
        restore_cf_driver(original_cf_driver)
      end
    end

    private

    def replace_aws_global_config
      config = Aws.config
      Aws.config = config.deep_dup
      config
    end

    def restore_aws_global_config(config)
      Aws.config = config
    end

    def replace_cf_driver
      driver = StackMaster.cloud_formation_driver
      StackMaster.cloud_formation_driver = AwsDriver::CloudFormation.new
      driver
    end

    def restore_cf_driver(driver)
      return if driver.nil?
      StackMaster.cloud_formation_driver = driver
    end

    def assume_role_credentials(account, role)
      credentials_key = "#{account}:#{role}"
      @credentials.fetch(credentials_key) do
        @credentials[credentials_key] = Aws::AssumeRoleCredentials.new(
          role_arn: "arn:aws:iam::#{account}:role/#{role}",
          role_session_name: "stack-master-assume-role-parameter-resolver"
        )
      end
    end
  end
end
