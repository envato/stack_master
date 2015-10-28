RSpec.describe StackMaster::Commands::Validate do

  subject(:validate) { described_class.new(config, region, stack_name) }
  let(:config) { instance_double(StackMaster::Config) }
  let(:region) { "us-east-1" }
  let(:stack_name) { "mystack" }
  let(:stack_definition) do
    StackMaster::Config::StackDefinition.new(
      region: 'us-east-1',
      stack_name: 'myapp_vpc',
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures')
    )
  end

  describe "#perform" do
    context "can find stack" do
      it "calls the validator to validate the stack definition" do
        allow(config).to receive(:find_stack).with(region, stack_name).and_return stack_definition
        expect(StackMaster::Validator).to receive(:perform).with(stack_definition)
        validate.perform
      end
    end

    context "can't find stack" do
      it "tells the user of the problem" do
        allow(config).to receive(:find_stack).with(region, stack_name).and_return nil
        expect { validate.perform }.to output(/Unable to find stack/).to_stderr
      end
    end
  end

end
