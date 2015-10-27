RSpec.describe StackMaster::Commands::Init do

  subject(:init_command) { described_class.new(region, stack_name) }
  let(:region) { "us-east-1" }
  let(:stack_name) { "test-stack" }

  describe "#perform" do
    it "creates a stack_master.yml file" do
      expect(IO).to receive(:write).with("stack_master.yml", "stacks:\n  us-east-1:\n    test-stack:\n      template: test-stack.json\n      tags:\n        environment: production\n")
      init_command.perform()
    end
  end

end
