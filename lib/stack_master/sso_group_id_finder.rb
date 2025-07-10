module StackMaster
  class SsoGroupIdFinder
    SsoGroupNotFound = Class.new(StandardError)

    def find(reference)
      output_regex = %r{(?:(?<region>[^:]+):)?(?<identity_store_id>[^:/]+)/(?<group_name>.+)}

      if !reference.is_a?(String) || !(match = output_regex.match(reference))
          raise ArgumentError, 'Sso group lookup parameter must be in the form of [region:]identity-store-id/group_name'
      end

      region = match[:region] || StackMaster.cloud_formation_driver.region
      client = Aws::IdentityStore::Client.new({ region: region })

      next_token = nil
      begin
        loop do
          response = client.list_groups({
            identity_store_id: match[:identity_store_id],
            next_token: next_token,
            max_results: 50
          })

          matching_group = response.groups.find { |group| group.display_name == match[:group_name] }
          return matching_group.group_id if matching_group
          break unless response.next_token
          next_token = response.next_token
        end
      rescue Aws::IdentityStore::Errors::ServiceError => e
          puts "Error calling ListGroups: #{e.message}"
      end

      raise SsoGroupNotFound, "No group with name #{match[:group_name]} found in identity store #{match[:identity_store_id]} in #{region}"
    end
  end
end
