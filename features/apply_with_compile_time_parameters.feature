Feature: Apply command with compile time parameters

  Background:
    Given a file named "stack_master.yml" with:
    """
          stacks:
            us-east-1:
              vpc:
                template: vpc.rb
          """
    And a directory named "parameters"
    And a file named "parameters/vpc.yml" with:
    """
          vpc_cidr: 10.200.2.0/23
          compile_time_parameters:
             private_subnet_cidrs:
              - 10.0.0.0/32:ap-southeast-2
              - 10.0.0.2/32:ap-southeast-1
          """
    And a directory named "templates"
    And a file named "templates/vpc.rb" with:
    """
          SparkleFormation.new(
              :vpc,
              {
                  compile_time_parameters: {
                      private_subnet_cidrs: {
                          type: :string,
                          multiple: true
                      }
                  }
              }
          ) do

            parameters.vpc_cidr do
              type 'String'
            end

            resources.vpc do
              type 'AWS::EC2::VPC'
              properties do
                cidr_block ref!(:vpc_cidr)
              end
            end

            state!(:private_subnet_cidrs).each_with_index do |item, index|
              private_subnet = item.split(':')
              private_cidr = private_subnet[0]
              private_az = private_subnet[1]
              resources.set!("subnet_private_#{index}".to_sym) do
                type 'AWS::EC2::Subnet'
                properties do
                  vpc_id ref!(:vpc)
                  availability_zone private_az
                  cidr_block private_cidr
                end
              end
            end

          end
          """

  Scenario: Run apply and create a new stack
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | vpc        | SubnetPrivate1      | CREATE_COMPLETE | AWS::EC2::Subnet           | 2020-10-29 00:00:00 |
      | 1        | 1        | vpc        | SubnetPrivate0      | CREATE_COMPLETE | AWS::EC2::Subnet           | 2020-10-29 00:00:00 |
      | 1        | 1        | vpc        | Vpc                 | CREATE_COMPLETE | AWS::EC2::VPC              | 2020-10-29 00:00:00 |
      | 1        | 1        | vpc        | vpc                 | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply us-east-1 vpc --trace`
    And the output should contain all of these lines:
      | +    "SubnetPrivate0": {                          |
      | +      "Type": "AWS::EC2::Subnet",                |
      | +      "Properties": {                            |
      | +        "VpcId": {                               |
      | +          "Ref": "Vpc"                           |
      | +        },                                       |
      | +        "AvailabilityZone": "ap-southeast-2",    |
      | +        "CidrBlock": "10.0.0.0/32"               |
      | +      }                                          |
      | +    },                                           |
      | +    "SubnetPrivate1": {                          |
      | +      "Type": "AWS::EC2::Subnet",                |
      | +      "Properties": {                            |
      | +        "VpcId": {                               |
      | +          "Ref": "Vpc"                           |
      | +        },                                       |
      | +        "AvailabilityZone": "ap-southeast-1",    |
      | +        "CidrBlock": "10.0.0.2/32"               |
      | +      }                                          |
      | +    }                                            |
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0