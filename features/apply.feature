Feature: Apply command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          myapp_vpc:
            template: myapp_vpc.rb
      """
    And a directory named "parameters"
    And a file named "parameters/myapp_vpc.yml" with:
      """
      VpcId: vpc-xxxxxx
      """
    And a directory named "templates"
    And a file named "templates/myapp_vpc.rb" with:
      """
      SparkleFormation.new(:test) do
        description "Test web template"
        set!('AWSTemplateFormatVersion', '2010-09-09')

        parameters.vpc_id do
          description 'VPC ID'
          type 'AWS::EC2::VPC::Id'
        end

        resources.test_sg do
          type 'AWS::EC2::SecurityGroup'
          properties do
            group_description 'Security group for comand cluster EC2 instances'
            vpc_id ref!(:vpc_id)
          end
        end
      end
      """
    And I set the environment variables to:
      | variable | value |
      | STUB_AWS | true  |

  Scenario: Run apply and create a new stack
    Given I set the environment variables to:
      | variable | value |
      | ANSWER   | y     |
    And I stub stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply us-east-1 myapp-vpc --trace` interactively
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "TestSg": {                                                               |
      | Parameters diff:                                                               |
      | "VpcId": "vpc-xxxxxx"                                                          |
      | 2020-10-29 00:00:00 +1100 myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE |
    Then the exit status should be 0
