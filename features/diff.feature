Feature: Diff command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        myapp_vpc:
          template: myapp_vpc.json
      """
    And a directory named "parameters"
    And a file named "parameters/myapp_vpc.yml" with:
      """
      KeyName: my-key
      """
    And a directory named "templates"
    And a file named "templates/myapp_vpc.json" with:
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

  Scenario: Run diff on a stack with no changes
    Given I stub the following stacks:
      | stack_id | stack_name | parameters          | region    |
      |        1 | myapp-vpc  | KeyName=changed-key | us-east-1 |
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
    When I run `stack_master diff us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | -KeyName: changed |
      | +KeyName: my-key  |
    Then the exit status should be 0

  Scenario: Run diff on a stack with parameter changes
    Given I stub the following stacks:
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
    When I run `stack_master diff us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
      | Stack diff: No changes      |
      | Parameters diff: No changes |
    Then the exit status should be 0

  Scenario: Run diff on a stack with template changes
    Given I stub the following stacks:
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
              "GroupDescription": "Changed description",
              "VpcId": {
                "Ref": "VpcId"
              }
            }
          }
        }
      }
      """
    When I run `stack_master diff us-east-1 myapp-vpc --trace`
    And the output should contain all of these lines:
    | -        "GroupDescription": "Changed description" |
    | +        "GroupDescription": "Test SG 2",          |
    Then the exit status should be 0

