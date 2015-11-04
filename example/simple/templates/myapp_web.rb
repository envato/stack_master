SparkleFormation.new(:myapp_web) do
  description "Test web template"

  parameters.vpc_id do
    description 'VPC ID'
    type 'String'
  end

  resources.web_sg do
    type 'AWS::EC2::SecurityGroup'
    properties do
      group_description 'Security group for web instances'
      vpc_id ref!(:vpc_id)
    end
  end
end
