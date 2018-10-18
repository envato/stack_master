Feature: Apply command with parameter_store parameter

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        vpc:
          template: vpc.rb
      """
    And a directory named "parameters"
    And a file named "parameters/vpc.yml" with:
      """
      vpc_cidr:
        parameter_store: "/cucumber-test-vpc-cidr"
      """
    And a SSM parameter named "/cucumber-test-vpc-cidr" with value "10.0.0.0/16" in region "us-east-2"
    And a directory named "templates"
    And a file named "templates/vpc.rb" with:
      """
      SparkleFormation.new(:vpc) do

        parameters.vpc_cidr do
          type 'String'
        end

        resources.vpc do
          type 'AWS::EC2::VPC'
          properties do
            cidr_block ref!(:vpc_cidr)
          end
        end

      end
      """

  Scenario: Run apply and create a new stack
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | vpc        | Vpc                 | CREATE_COMPLETE | AWS::EC2::VPC              | 2020-10-29 00:00:00 |
      | 1        | 1        | vpc        | vpc                 | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply us-east-2 vpc --trace`
    And the output should contain all of these lines:
      | +---                  |
      | +VpcCidr: 10.0.0.0/16 |
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0
