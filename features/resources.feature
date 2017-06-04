Feature: Resources command

  Background:
    Given a file named "stack_master.yml" with:
      """
      environments:
        prod:
          stacks:
            myapp_vpc:
              template: myapp_vpc.rb
      """
    And a directory named "templates"
    And a file named "templates/myapp_vpc.rb" with:
      """
      SparkleFormation.new(:myapp_vpc) do
        description "Test template"
        set!('AWSTemplateFormatVersion', '2010-09-09')
        resources.vpc do
          type 'AWS::EC2::VPC'
          properties do
            cidr_block '10.200.0.0/16'
          end
        end
      end
      """

  Scenario: Show resources
    Given I stub the following stacks:
      | stack_id | stack_name      | parameters       | region    |
      | 1        | prod-myapp-vpc  | KeyName=my-key   | us-east-1 |
    And I stub the following stack resources:
      | stack_name | logical_resource_id  | resource_type | timestamp           | resource_status |
      | prod-myapp-vpc  | Vpc             | AWS::EC2::Vpc | 2015-11-02 06:41:58 | CREATE_COMPLETE |
    When I run `stack_master resources prod myapp-vpc --trace`
    And the output should contain all of these lines:
      | Vpc                 |
      | AWS::EC2::Vpc       |
      | 2015-11-02 06:41:58 |
      | CREATE_COMPLETE     |

  Scenario: Fails when the stack doesn't exist
    When I run `stack_master resources prod myapp-vpc --trace`
    And the output should contain "Stack doesn't exist"
