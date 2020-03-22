Feature: Validate command with missing parameters

  Background:
    Given a file named "stack_master.yml" with:
      """
      stacks:
        us_east_1:
          stack1:
            template: stack1.rb
      """
    And a directory named "parameters"
    And a file named "parameters/stack1.yml" with:
      """
      ParameterOne: populated
      """
    And a directory named "templates"
    And a file named "templates/stack1.rb" with:
      """
      SparkleFormation.new(:awesome_stack) do
        parameters do
          parameter_one.type 'String'
          parameter_two.type 'String'
          parameter_three.type 'String'
        end
        resources.vpc do
          type 'AWS::EC2::VPC'
          properties.cidr_block '10.200.0.0/16'
        end
        outputs.vpc_id.value ref!(:vpc)
      end
      """

  Scenario: Reports the missing parameter values
    Given I stub CloudFormation validate calls to pass validation
    When I run `stack_master validate us-east-1 stack1`
    Then the output should contain all of these lines:
      | stack1: invalid                                                              |
      | Empty/blank parameters detected. Please provide values for these parameters: |
      | - ParameterTwo                                                               |
      | - ParameterThree                                                             |
      | Parameters will be read from files matching the following globs:             |
      | - parameters/stack1.y*ml                                                     |
      | - parameters/us-east-1/stack1.y*ml                                           |
    And the exit status should be 1
