Feature: Apply command with assume role parameter resolvers

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us-east-2:
          vpc:
            template: vpc.rb
          myapp_web:
            template: myapp_web.rb
      """
    And a directory named "parameters"
    And a file named "parameters/myapp_web.yml" with:
      """
      vpc_id:
        role: my-role
        account: 1234567890
        stack_output: vpc/vpc_id
      """
    And a directory named "templates"
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
    Given I stub the CloudFormation driver
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    And I stub the following stacks:
      | stack_id | stack_name | parameters           | outputs      | region    |
      | 1        | vpc        | VpcCidr=10.0.0.16/22 | VpcId=vpc-id | us-east-2 |
      | 2        | myapp_web  |                      |              | us-east-2 |
    Then I expect the role "my-role" is assumed in account "1234567890"
    When I run `stack_master apply us-east-2 myapp_web --trace`
    And the output should contain all of these lines:
      | +---           |
      | +VpcId: vpc-id |
    Then the exit status should be 0
