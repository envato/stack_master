Feature: Events command

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

  Scenario: View events
    Given I stub the following stack events:
      | stack_id | event_id | stack_name      | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | prod-myapp-vpc  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | prod-myapp-vpc  | prod-myapp-vpc      | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master events prod myapp-vpc --trace`
    And the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} prod-myapp-vpc AWS::CloudFormation::Stack CREATE_COMPLETE/
