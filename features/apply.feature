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
      KeyName: my-key
      """
    And a file named "parameters/myapp_web.yml" with:
      """
      VpcId: vpc-blah
      """
    And a directory named "templates"
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

  Scenario: Run apply and create a new stack
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff:          |
      | +    "Vpc": {        |
      | Parameters diff:     |
      | KeyName: my-key      |
      | Proposed change set: |
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0

  Scenario: Run apply and don't create the stack
    Given I will answer prompts with "n"
    When I run `stack_master apply us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff:          |
      | +    "Vpc": {        |
      | Parameters diff:     |
      | KeyName: my-key      |
      | aborted              |
      | Proposed change set: |
    And the output should not match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0

  Scenario: Run apply with region only and create 2 stacks
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply us-east-1 --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "Vpc": {                                                                  |
      | Parameters diff:                                                               |
      | KeyName: my-key                                                                |

  Scenario: Run apply nothing and create 2 stacks
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "Vpc": {                                                                  |
      | Parameters diff:                                                               |
      | KeyName: my-key                                                                |
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-web AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-web AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0

  Scenario: Create stack with --changed
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master --changed apply us-east-1 --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "Vpc": {                                                                  |
      | Parameters diff:                                                               |
      | KeyName: my-key                                                                |

  Scenario: Run apply with 2 specific stacks and create 2 stacks
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply us-east-1 myapp-vpc us-east-1 myapp-web --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "Vpc": {                                                                  |
      | Parameters diff:                                                               |
      | KeyName: my-key                                                                |
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-web AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-web AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0

  Scenario: Update a stack
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 |
    And I stub a template for the stack "myapp-vpc":
      """
      {
        "Description": "Test template",
        "AWSTemplateFormatVersion": "2010-09-09",
        "Parameters": {
          "KeyName": {
            "Description": "Key Name",
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
    When I run `stack_master apply us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | -    "TestSg2": {                                                              |
      | Parameters diff: No changes                                                    |
      | ========================================                                       |
      | Proposed change set:                                                           |
      | Replace                                                                        |
      | ========================================                                       |
      | Apply change set (y/n)?                                                        |
    Then the exit status should be 0


  Scenario: Run apply to update a stack and answer no
    Given I will answer prompts with "n"
    And I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 |
    And I stub a template for the stack "myapp-vpc":
      """
      {
        "Description": "Test template",
        "AWSTemplateFormatVersion": "2010-09-09",
        "Parameters": {
          "KeyName": {
            "Description": "Key Name",
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
    When I run `stack_master apply us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | -    "TestSg2": {                                                              |
      | Parameters diff: No changes                                                    |
      | ========================================                                       |
      | Proposed change set:                                                           |
      | Replace                                                                        |
      | ========================================                                       |
      | Apply change set (y/n)?                                                        |
    Then the exit status should be 0

  Scenario: Update a stack that has changed with --changed
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 |
    And I stub a template for the stack "myapp-vpc":
      """
      {
        "Description": "Test template",
        "AWSTemplateFormatVersion": "2010-09-09",
        "Parameters": {
          "KeyName": {
            "Description": "Key Name",
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
    When I run `stack_master --changed apply us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | -    "TestSg2": {                                                              |
      | Parameters diff: No changes                                                    |
    Then the exit status should be 0

  Scenario: Update an existing stack that hasn't changed with --changed
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 |
    And I stub a template for the stack "myapp-vpc":
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
    When I run `stack_master --changed apply us-east-1 myapp-vpc --trace`
    And the output should not contain all of these lines:
      | Stack diff:                                                                    |
      | -    "TestSg2": {                                                              |
      | Parameters diff: No changes                                                    |
    Then the exit status should be 0

  Scenario: Create a stack using a stack output resolver
    Given a file named "parameters/myapp_web.yml" with:
      """
      VpcId:
        stack_output: myapp-vpc/VpcId
      """
    And I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-web  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | region    | outputs          |
      | 1        | myapp-vpc  | us-east-1 | VpcId=vpc-xxxxxx |
    When I run `stack_master apply us-east-1 myapp-web --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "TestSg": {                                                               |
      | Parameters diff:                                                               |
      | VpcId: vpc-xxxxxx                                                              |
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-web AWS::CloudFormation::Stack CREATE_COMPLETE/
    Then the exit status should be 0

  Scenario: Create a stack with a notification ARN and a stack update policy
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          myapp_vpc:
            template: myapp_vpc.rb
            notification_arns:
              - test_arn
            stack_policy_file: no_rds_replacement.json
      """
    And a file named "policies/no_rds_replacement.json" with:
      """
      {}
      """
    And I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-vpc  | myapp-vpc           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters       | region    |
      | 1        | myapp-vpc  | KeyName=my-key   | us-east-1 |
    And I stub a template for the stack "myapp-vpc":
      """
      {
        "Description": "Test template",
        "AWSTemplateFormatVersion": "2010-09-09",
        "Parameters": {
          "KeyName": {
            "Description": "Key Name",
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
    When I run `stack_master apply us-east-1 myapp-vpc --trace`
    Then the stack "myapp-vpc" should have a policy with the following:
      """
      {}
      """
    And the stack "myapp-vpc" should contain this notification ARN "test_arn"
    Then the exit status should be 0
