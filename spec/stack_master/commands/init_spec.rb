RSpec.describe StackMaster::Commands::Init do
  subject(:init_command) { described_class.new(options, region, stack_name) }
  let(:region) { "us-east-1" }
  let(:stack_name) { "test-stack" }
  let(:options) { double(overwrite: false) }

  describe "#perform" do
    it "creates all the expected files" do
      expect(IO)
        .to receive(:write)
        .with("stack_master.yml", <<~YAML)
          stacks:
            us-east-1:
              test-stack:
                template: test-stack.json
                tags:
                  environment: production
        YAML

      expect(IO)
        .to receive(:write)
        .with("parameters/test-stack.yml", <<~YAML)
          # Add parameters here:
          # param1: value1
          # param2: value2
        YAML

      expect(IO)
        .to receive(:write)
        .with("parameters/us-east-1/test-stack.yml", <<~YAML)
          # Add parameters here:
          # param1: value1
          # param2: value2
        YAML

      expect(IO)
        .to receive(:write)
        .with("templates/test-stack.json", <<~JSON)
          {
            "AWSTemplateFormatVersion" : "2010-09-09",
            "Description" : "Cloudformation stack for test-stack",

            "Parameters" : {
              "InstanceType" : {
                "Description" : "EC2 instance type",
                "Type" : "String"
              }
            },

            "Mappings" : {
            },

            "Resources" : {
            },

            "Outputs" : {
            }
          }
        JSON

      init_command.perform
    end
  end
end
