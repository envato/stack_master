Feature: Apply command

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          myapp-web:
            template: myapp-web.rb
      """
    And a directory named "parameters"
    And a file named "parameters/myapp-web.yml" with:
      """
      VpcId: vpc-id-in-properties
      """
    And a directory named "templates"
    And a file named "templates/myapp-web.rb" with:
      """
      SparkleFormation.new(:myapp_web) do
        description "Test template"
        parameters.vpc_id.type 'AWS::EC2::VPC::Id'
        resources.test_sg do
          type 'AWS::EC2::SecurityGroup'
          properties do
            group_description 'Test SG'
            vpc_id ref!(:vpc_id)
          end
        end
      end
      """

  Scenario: Run apply with dash in filenames
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-web  | TestSg              | CREATE_COMPLETE | AWS::EC2::SecurityGroup    | 2020-10-29 00:00:00 |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply us-east-1 myapp-web --trace`
    And the output should contain all of these lines:
      | Stack diff:                                                                    |
      | +    "TestSg": {                                                               |
      | Parameters diff:                                                               |
      | +VpcId: vpc-id-in-properties                                                   |
    Then the exit status should be 0
