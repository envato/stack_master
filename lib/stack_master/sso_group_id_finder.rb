module StackMaster
  class SsoGroupIdFinder
    SSOGroupNotFound = Class.new(StandardError)
    SSOIdentityStoreInvalid = Class.new(StandardError)

    def initialize(region)
      @client = Aws::IdentityStore::Client.new({ region: region })
    end

    def find(reference, identity_store_id)
      raise ArgumentError, 'SSO Group Name must be a non-empty string' unless reference.is_a?(String) && !reference.empty?

      next_token = nil
      all_sso_groups = []
      begin
        loop do
          response = @client.list_groups({
            identity_store_id: identity_store_id,
            next_token: next_token,
            max_results: 50
          })

          matching_group = response.groups.find { |group| group.display_name == reference }
          return matching_group.group_id if matching_group
          break unless response.next_token
          next_token = response.next_token
        end
      rescue Aws::IdentityStore::Errors::ServiceError => e
          puts "Error calling ListGroups: #{e.message}"
      end

      raise SSOGroupNotFound, "No group with name #{reference} found"
    end
  end
end
