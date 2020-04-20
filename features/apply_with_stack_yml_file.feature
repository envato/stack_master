Feature: Apply command with stack.yml file

  Background:
    Given a file named "stack_master.yml" with:
      """
      stack_defaults:
        tags:
          Application: myapp
        region: us-east-1
      """
    And a file named "myapp-web.yml" with:
      """
      template: myapp.rb
      parameters:
        KeyName: my-key
      """
    And a directory named "templates"
    And a file named "templates/myapp.rb" with:
      """
      SparkleFormation.new(:myapp) do
        description "Test template"

        parameters.key_name do
          description 'Key name'
          type 'String'
        end

        resources.instance do
          type 'AWS::EC2::Instance'
          properties do
            image_id 'ami-0080e4c5bc078760e'
            instance_type 't2.micro'
          end
        end
      end
      """

  Scenario: Run apply with stack-name.yml argument
    Given I stub the following stack events:
      | stack_id | event_id | stack_name | logical_resource_id | resource_status | resource_type              | timestamp           |
      | 1        | 1        | myapp-web  | myapp-web           | CREATE_COMPLETE | AWS::CloudFormation::Stack | 2020-10-29 00:00:00 |
    When I run `stack_master apply myapp-web.yml --trace`
    Then the output should match /2020-10-29 00:00:00 (\+|\-)[0-9]{4} myapp-web AWS::CloudFormation::Stack CREATE_COMPLETE/
    And the output should contain all of these lines:
      | Stack diff:          |
      | +    "Instance": {   |
      | Parameters diff:     |
      | KeyName: my-key      |
      | Proposed change set: |
    And the exit status should be 0
