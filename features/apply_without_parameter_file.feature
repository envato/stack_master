Feature: Apply command without parameter files

  Background:
    Given a directory named "templates"
    And a file named "templates/myapp.rb" with:
      """
      SparkleFormation.new(:myapp) do
        parameters.key_name.type 'String'
        resources.vpc do
          type 'AWS::EC2::VPC'
          properties.cidr_block '10.200.0.0/16'
        end
        outputs.vpc_id.value ref!(:vpc)
      end
      """

  Scenario: With a region alias
    Given a file named "stack_master.yml" with:
      """
      region_aliases:
        production: us-east-1
        staging: ap-southeast-2
      stacks:
        production:
          myapp:
            template: myapp.rb
      """
    When I run `stack_master apply production myapp --trace`
    Then the output should contain all of these lines:
      | Empty/blank parameters detected. Please provide values for these parameters: |
      | - KeyName                                                                    |
      | Parameters will be read from files matching the following globs:             |
      | - parameters/myapp.y*ml                                                      |
      | - parameters/us-east-1/myapp.y*ml                                            |
      | - parameters/production/myapp.y*ml                                           |
    And the exit status should be 1

  Scenario: Without a region alias
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us-east-1:
          myapp:
            template: myapp.rb
      """
    When I run `stack_master apply us-east-1 myapp --trace`
    Then the output should contain all of these lines:
      | Empty/blank parameters detected. Please provide values for these parameters: |
      | - KeyName                                                                    |
      | Parameters will be read from files matching the following globs:             |
      | - parameters/myapp.y*ml                                                      |
      | - parameters/us-east-1/myapp.y*ml                                            |
    And the output should not contain "- parameters/production/myapp.y*ml"
    And the exit status should be 1
