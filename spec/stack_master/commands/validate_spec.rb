RSpec.describe StackMaster::Commands::Validate do

  subject(:validate) { described_class.new(config, stack_definition, options) }
  let(:config) { instance_double(StackMaster::Config) }
  let(:region) { "us-east-1" }
  let(:stack_name) { "mystack" }
  let(:options) { Commander::Command::Options.new }
  let(:stack_definition) do
    StackMaster::StackDefinition.new(
      region: region,
      stack_name: stack_name,
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures')
    )
  end

  describe "#perform" do
    context "can find stack" do
      it "calls the validator to validate the stack definition" do
        expect(StackMaster::Validator).to receive(:valid?).with(stack_definition, config, options)
        validate.perform
      end
    end
  end

end
