RSpec.describe StackMaster::Validator do

  subject(:validator) { described_class.new(stack_definition, config) }
  let(:config) { StackMaster::Config.new({'environments' => {}}, '/base_dir') }
  let(:stack_name) { 'myapp_vpc' }
  let(:stack_definition) do
    StackMaster::StackDefinition.new(
        region: 'us-east-1',
        stack_name: stack_name,
        template: 'myapp_vpc.json',
        tags: {'environment' => 'production'},
        base_dir: File.expand_path('spec/fixtures'),
    )
  end
  let(:cf) { Aws::CloudFormation::Client.new(region: "us-east-1") }
  let(:parameter_hash) { {template_parameters: {}, compile_time_parameters: {'DbPassword' => {'secret' => 'db_password'}}} }
  let(:resolved_parameters) { {'DbPassword' => 'sdfgjkdhlfjkghdflkjghdflkjg', 'InstanceType' => 't2.medium'} }
  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return cf
    allow(StackMaster::ParameterLoader).to receive(:load).and_return(parameter_hash)
    allow(StackMaster::ParameterResolver).to receive(:resolve).and_return(resolved_parameters)
  end

  describe "#perform" do
    context "template body is valid" do
      before do
        cf.stub_responses(:validate_template, nil)
      end
      it "tells the user everything will be fine" do
        expect { validator.perform }.to output(/myapp_vpc: valid/).to_stdout
      end
    end

    context "invalid template body" do
      before do
        cf.stub_responses(:validate_template, Aws::CloudFormation::Errors::ValidationError.new('a', 'Problem'))
      end
      it "informs the user of their stupdity" do
        expect { validator.perform }.to output(/myapp_vpc: invalid/).to_stdout
      end
    end

    context "validate is called from from a continuous integration system with no access to secrets" do
      let(:stack_name) { 'myapp_vpc_with_secrets' }
      let(:secret) { instance_double(StackMaster::ParameterResolvers::Secret) }
      before do
        allow(StackMaster::ParameterResolvers::Secret).to receive(:new).and_return(secret)
      end
      it "does not prompt for the secret key" do
        expect(secret).not_to receive(:resolve)
        validator.perform
      end
    end
  end

end
