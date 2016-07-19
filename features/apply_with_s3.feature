Feature: Apply command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stack_defaults:
        s3:
          bucket: my-bucket
          region: us-east-1
          prefix: cfn_templates/my-app
      stacks:
        us_east_1:
          myapp_vpc:
            template: myapp_vpc.rb
            files:
              - user_data.sh
      """
    And a directory named "parameters"
    And a file named "parameters/myapp_vpc.yml" with:
      """
      KeyName: my-key
      """
    And a file named "parameters/myapp_web.yml" with:
      """
      VpcId: vpc-blah
      """
    And a directory named "templates"
    And a file named "files/user_data.sh" with:
      """
      #!/bin/bash
      echo "HI"
      """
    And a file named "templates/myapp_vpc.rb" with:
      """
      SparkleFormation.new(:myapp_vpc) do
        description "Test template"
        set!('AWSTemplateFormatVersion', '2010-09-09')

        parameters.key_name do
          description 'Key name'
          type 'String'
        end

        resources.vpc do
          type 'AWS::EC2::VPC'
          properties do
            cidr_block '10.200.0.0/16'
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

  Scenario: Run apply and create a new stack
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "Vpc": {                                                                  |
      | Parameters diff:                                                               |
      | KeyName: my-key                                                                |
    And the output should match /2020-10-29 00:00:00 \+[0-9]{4} myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    And an S3 file in bucket "my-bucket" with key "cfn_templates/my-app/myapp_vpc.json" exists with content:
      """
      {
        "Description": "Test template",
        "AWSTemplateFormatVersion": "2010-09-09",
        "Parameters": {
          "KeyName": {
            "Description": "Key name",
            "Type": "String"
          }
        },
        "Resources": {
          "Vpc": {
            "Type": "AWS::EC2::VPC",
            "Properties": {
              "CidrBlock": "10.200.0.0/16"
            }
          }
        },
        "Outputs": {
          "VpcId": {
            "Description": "A VPC ID",
            "Value": {
              "Ref": "Vpc"
            }
          }
        }
      }
      """
    And an S3 file in bucket "my-bucket" with key "cfn_templates/my-app/user_data.sh" exists with content:
      """
      #!/bin/bash
      echo "HI"
      """
    Then the exit status should be 0
