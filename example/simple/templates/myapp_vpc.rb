SparkleFormation.new(:myapp_vpc) do
  description "A test VPC template"

  resources.vpc do
    type 'AWS::EC2::VPC'
    properties do
      cidr_block '10.200.0.0/16'
    end
  end

  parameters.vpc_az_1 do
    description 'VPC AZ 1'
    type 'AWS::EC2::AvailabilityZone::Name'
  end

  resources.public_subnet do
    type 'AWS::EC2::Subnet'
    properties do
      vpc_id ref!(:vpc)
      cidr_block '10.200.1.0/24'
      availability_zone ref!(:vpc_az_1)
      tags _array(
        { Key: 'Name', Value: 'PublicSubnet' },
        { Key: 'network', Value: 'public' }
      )
    end
  end

  outputs do
    vpc_id do
      description 'VPC ID'
      value ref!(:vpc)
    end
    public_subnet do
      description 'Public subnet'
      value ref!(:public_subnet)
    end
  end
end
