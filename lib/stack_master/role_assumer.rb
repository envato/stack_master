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

      role_credentials = assume_role_credentials(account, role)
      with_temporary_credentials(role_credentials) do
        with_temporary_cf_driver do
          block.call
        end
      end
    end

    private

    def with_temporary_credentials(credentials, &block)
      original_aws_config = Aws.config
      Aws.config = original_aws_config.deep_dup
      Aws.config[:credentials] = credentials
      block.call
    ensure
      Aws.config = original_aws_config
    end

    def with_temporary_cf_driver(&block)
      original_driver = StackMaster.cloud_formation_driver
      new_driver = original_driver.class.new
      new_driver.set_region(original_driver.region)
      StackMaster.cloud_formation_driver = new_driver
      block.call
    ensure
      StackMaster.cloud_formation_driver = original_driver
    end

    def assume_role_credentials(account, role)
      credentials_key = "#{account}:#{role}"
      @credentials.fetch(credentials_key) do
        @credentials[credentials_key] = Aws::AssumeRoleCredentials.new(
          {
            region: StackMaster.cloud_formation_driver.region,
            role_arn: "arn:aws:iam::#{account}:role/#{role}",
            role_session_name: 'stack-master-role-assumer'
          }
        )
      end
    end
  end
end
