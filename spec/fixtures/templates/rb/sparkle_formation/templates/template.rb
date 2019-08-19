SparkleFormation.new(:myapp_vpc_2) do
  description "A test VPC template"

  resources.vpc do
    type 'AWS::EC2::VPC'
    properties do
      cidr_block '10.200.0.0/16'
    end
  end
end
