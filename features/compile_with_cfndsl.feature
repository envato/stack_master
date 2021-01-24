Feature: Compile command with a CfnDsl template

  Scenario: Run compile stack on CfnDsl template
    Given a file named "stack_master.yml" with:
      """
      template_compilers:
        rb: cfndsl
      stacks:
        us_east_1:
          myapp_vpc:
            template: myapp_vpc.rb
      """
    And a directory named "parameters"
    And a file named "parameters/myapp_vpc.yml" with:
      """
      KeyName: my-key
      compile_time_parameters:
        cidr_block: 10.200.0.0/16
      """
    And a directory named "templates"
    And a file named "templates/myapp_vpc.rb" with:
      """
      CloudFormation do
        Description "Test template"

        Parameter("KeyName") do
          Description "Key name"
          Type "String"
        end

        VPC(:Vpc) do
          CidrBlock external_parameters[:CidrBlock]
        end

        Output(:VpcId) do
          Description "A VPC ID"
          Value Ref("Vpc")
        end
      end
      """
    When I run `stack_master compile us-east-1 myapp-vpc`
    Then the output should contain all of these lines:
      | Executing compile on myapp-vpc in us-east-1 |
      |   "AWSTemplateFormatVersion": "2010-09-09", |
      |   "Description": "Test template",           |
      |   "Parameters": {                           |
      |     "KeyName": {                            |
      |       "Type": "String"                      |
      |       "Description": "Key name"             |
      |     }                                       |
      |   },                                        |
      |   "Resources": {                            |
      |     "Vpc": {                                |
      |       "Properties": {                       |
      |         "CidrBlock": "10.200.0.0/16"        |
      |       },                                    |
      |       "Type": "AWS::EC2::VPC"               |
      |     }                                       |
      |   },                                        |
      |   "Outputs": {                              |
      |     "VpcId": {                              |
      |       "Description": "A VPC ID",            |
      |       "Value": {                            |
      |         "Ref": "Vpc"                        |
      |       }                                     |
      |     }                                       |
      |   }                                         |
      | }                                           |
    And the exit status should be 0
