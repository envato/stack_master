module StackMaster
  class SecurityGroupFinder
    SecurityGroupNotFound = Class.new(StandardError)
    MultipleSecurityGroupsFound = Class.new(StandardError)

    def initialize(region)
      @resource = Aws::EC2::Resource.new({ region: region })
    end

    def find(reference)
      unless reference.is_a?(String) && !reference.empty?
        raise ArgumentError, 'Security group references must be non-empty strings'
      end

      groups = @resource.security_groups({
                                           filters: [
                                             {
                                               name: "group-name",
                                               values: [reference],
                                             }
                                           ],
                                         })

      raise SecurityGroupNotFound, "No security group with name #{reference} found" unless groups.any?
      raise MultipleSecurityGroupsFound, "More than one security group with name #{reference} found" if groups.count > 1

      groups.first.id
    end
  end
end
