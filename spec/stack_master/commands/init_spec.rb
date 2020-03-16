RSpec.describe StackMaster::Commands::Init do

  subject(:init_command) { described_class.new(options, region, stack_name) }
  let(:region) { "us-east-1" }
  let(:stack_name) { "test-stack" }
  let(:options) { double(overwrite: false)}

  describe "#perform" do
    it "creates all the expected files" do
      expect(IO).to receive(:write).with("stack_master.yml", "stacks:\n  us-east-1:\n    test-stack:\n      template: test-stack.json\n      tags:\n        environment: production\n")
      expect(IO).to receive(:write).with("parameters/test-stack.yml", "# Add parameters here:\n# param1: value1\n# param2: value2\n")
      expect(IO).to receive(:write).with("parameters/us-east-1/test-stack.yml", "# Add parameters here:\n# param1: value1\n# param2: value2\n")
      expect(IO).to receive(:write).with("templates/test-stack.json", "{\n  \"AWSTemplateFormatVersion\" : \"2010-09-09\",\n  \"Description\" : \"Cloudformation stack for test-stack\",\n\n  \"Parameters\" : {\n    \"InstanceType\" : {\n      \"Description\" : \"EC2 instance type\",\n      \"Type\" : \"String\"\n    }\n  },\n\n  \"Mappings\" : {\n  },\n\n  \"Resources\" : {\n  },\n\n  \"Outputs\" : {\n  }\n}\n")
      init_command.perform()
    end
  end

end
