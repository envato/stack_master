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
        description "Test template"
        set!('AWSTemplateFormatVersion', '2010-09-09')

        parameters.vpc_id do
          description 'VPC ID'
          type 'AWS::EC2::VPC::Id'
        end

        resources.test_sg do
          type 'AWS::EC2::SecurityGroup'
          properties do
            group_description 'Test SG'
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
    And I stub the following stack events:
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

  Scenario: Run apply and don't create the stack
    Given I set the environment variables to:
      | variable | value |
      | ANSWER   | n     |
    When I run `stack_master apply us-east-1 myapp-vpc --trace` interactively
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "TestSg": {                                                               |
      | Parameters diff:                                                               |
      | "VpcId": "vpc-xxxxxx"                                                          |
      | aborted                                                                        |
    And the output should not contain all of these lines:
      | 2020-10-29 00:00:00 +1100 myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE |
    Then the exit status should be 0

  Scenario: Run apply on an existing stack
    Given I set the environment variables to:
      | variable | value |
      | ANSWER   | y     |
    And I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | VpcId=vpc-xxxxxx | us-east-1 |
    And I stub a template for the stack "myapp-vpc":
      """
      {
        "Description": "Test template",
        "AWSTemplateFormatVersion": "2010-09-09",
        "Parameters": {
          "VpcId": {
            "Description": "VPC ID",
            "Type": "String"
          },
          "Test": {
            "Description": "test",
            "Type": "String"
          }
        },
        "Resources": {
          "TestSg": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
              "GroupDescription": "Test SG",
              "VpcId": {
                "Ref": "VpcId"
              }
            }
          },
          "TestSg2": {
            "Type": "AWS::EC2::SecurityGroup",
            "Properties": {
              "GroupDescription": "Test SG 2",
              "VpcId": {
                "Ref": "VpcId"
              }
            }
          }
        }
      }
      """
    When I run `stack_master apply us-east-1 myapp-vpc --trace` interactively
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | -    "TestSg2": {                                                              |
      | Parameters diff: No changes                                                    |
    Then the exit status should be 0
