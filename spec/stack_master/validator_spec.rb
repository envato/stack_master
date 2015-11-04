RSpec.describe StackMaster::Validator do

  subject(:validator) { described_class.new(stack_definition) }
  let(:stack_definition) do
    StackMaster::StackDefinition.new(
      region: 'us-east-1',
      stack_name: 'myapp_vpc',
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures'),
    )
  end
  let(:cf) { Aws::CloudFormation::Client.new(region: "us-east-1") }
  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return cf
  end

  describe "#perform" do
    context "template body is valid" do
      before do
        cf.stub_responses(:validate_template, nil)
      end
      it "tells the user everything will be fine" do
        expect { validator.perform }.to output(/Valid/).to_stdout
      end
    end

    context "invalid template body" do
      before do
        cf.stub_responses(:validate_template, Aws::CloudFormation::Errors::ValidationError.new('a', 'Problem'))
      end
      it "informs the user of their stupdity" do
        expect { validator.perform }.to output(/Validation Failed/).to_stderr
      end
    end
  end
  
end
