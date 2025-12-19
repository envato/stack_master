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

      begin
        response = client.get_group_id(
          {
            identity_store_id: match[:identity_store_id],
            alternate_identifier: {
              unique_attribute: {
                attribute_path: 'displayName',
                attribute_value: match[:group_name]
              }
            }
          }
        )
        return response.group_id
      rescue Aws::IdentityStore::Errors::ServiceError => e
        puts "Error calling GetGroupId: #{e.message}"
      end

      raise SsoGroupNotFound,
            "No group with name #{match[:group_name]} found in identity store #{match[:identity_store_id]} in #{region}"
    end
  end
end
