Feature: Apply command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          myapp_vpc:
            template: myapp_vpc.rb
          myapp_web:
            template: myapp_web.rb
      """
    And a directory named "parameters"
    And a file named "parameters/myapp_vpc.yml" with:
      """
      ip_range: 10.160.0.0/16
      """
    And a file named "parameters/myapp_web.yml" with:
      """
      VpcId:
        stack_output: myapp_vpc/vpc_id
      """
    And a directory named "templates"
    And a file named "templates/myapp_vpc.rb" with:
      """
      SparkleFormation.new(:myapp_vpc) do
        description "Test template"
        set!('AWSTemplateFormatVersion', '2010-09-09')

        parameters.ip_range do
          description 'IP CIDR'
          type 'String'
        end

        resources.vpc do
          type 'AWS::EC2::VPC'
          properties do
            cidr_block ref!(:ip_range)
          end
        end

        outputs do
          vpc_id do
            description 'A VPC ID'
            value ref!(:vpc)
          end
        end
      end
      """
    And a file named "templates/myapp_web.rb" with:
      """
      SparkleFormation.new(:myapp_web) do
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

   Scenario: Update a stack that does not cause a replacement
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | Vpc                 | UPDATE_COMPLETE | AWS::EC2::VPC    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | UPDATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    | outputs        |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 | VpcId=vpc-1111 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 2        | myapp-web  | VpcId=vpc-1111   | us-east-1 |
    And I stub a template for the stack "myapp-vpc":
      """
      {
        "Description": "Test template",
        "AWSTemplateFormatVersion": "2010-09-09",
        "Parameters": {
          "IpRange": {
            "Description": "Ip CIDR",
            "Type": "String"
          }
        },
        "Resources": {
          "Vpc": {
            "Type": "AWS::EC2::VPC",
            "Properties": {
              "CidrBlock": "10.161.0.0/16",
              "EnableDnsSupport": "true"
            }
          }
        },
        "Outputs": {
          "VpcId": {
            "Value": { "Ref": "Vpc" }
          }
        }
      }
      """


    When I run `stack_master apply us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                  |
      | -        "EnableDnsSupport": "true"                                          |
      | Proposed change set:                                                         |
      | Replace                                                                      |
      | Apply change set (y/n)?                                                      |
    And the output should not contain all of these lines:
      | A dependent stack "myapp-web" is now out of date because of this change.     |
      | Apply this stack now (y/n)?                                                  |
    Then the exit status should be 0

   Scenario: Update a stack that causes a replacement
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | Vpc                 | CREATE_COMPLETE | AWS::EC2::VPC    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    | outputs        |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 | VpcId=vpc-1111 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 2        | myapp-web  | VpcId=vpc-9999   | us-east-1 |
    And I stub a template for the stack "myapp-vpc":
      """
      {
        "Description": "Test template",
        "AWSTemplateFormatVersion": "2010-09-09",
        "Parameters": {
          "IpRange": {
            "Description": "Ip CIDR",
            "Type": "String"
          }
        },
        "Resources": {
          "Vpc": {
            "Type": "AWS::EC2::VPC",
            "Properties": {
              "CidrBlock": "10.161.0.0/16"
            }
          }
        },
        "Outputs": {
          "VpcId": {
            "Value": { "Ref": "Vpc" }
          }
        }
      }
      """
    When I run `stack_master apply us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                  |
      | -        "CidrBlock": "10.161.0.0/16"                                        |
      | Proposed change set:                                                         |
      | Replace                                                                      |
      | Apply change set (y/n)?                                                      |
      | A dependent stack "myapp-web" is now out of date because of this change.     |
      | Apply this stack now (y/n)?                                                  |
    Then the exit status should be 0
