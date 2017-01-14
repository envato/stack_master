RSpec.describe StackMaster::Stack do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp_vpc' }
  let(:stack_id) { '1' }
  let(:stack_policy_body) { '{}' }
  let(:cf) { Aws::CloudFormation::Client.new }
  subject(:stack) { StackMaster::Stack.find(region, stack_name) }

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
  end

  describe '.find' do
    context 'when the stack exists in AWS' do
      let(:parameters) {
        [
          {parameter_key: 'param1', parameter_value: 'value1'},
          {parameter_key: 'param2', parameter_value: 'value2'}
        ]
      }
      before do
        cf.stub_responses(:describe_stacks, stacks: [{ stack_id: stack_id, stack_name: stack_name, creation_time: Time.now, stack_status: 'UPDATE_COMPLETE', parameters: parameters, notification_arns: ['test_arn'], role_arn: 'test_service_role_arn'}])
        cf.stub_responses(:get_template, template_body: "{}")
        cf.stub_responses(:get_stack_policy, stack_policy_body: stack_policy_body)
      end

      it 'returns a stack object with a stack_id' do
        expect(stack.stack_id).to eq stack_id
      end

      it "returns a template body" do
        expect(stack.template_body).to eq "{}"
      end

      it 'parses parameters into a hash' do
        expect(stack.parameters).to eq({'param1' => 'value1', 'param2' => 'value2'})
      end

      it 'sets role_arn' do
        expect(stack.role_arn).to eq('test_service_role_arn')
      end
      
      it 'sets notification_arns' do
        expect(stack.notification_arns).to eq(['test_arn'])
      end

      it 'sets the stack policy' do
        expect(stack.stack_policy_body).to eq stack_policy_body
      end
    end

    context 'when the stack does not exist in AWS' do
      before do
        cf.stub_responses(:describe_stacks, Aws::CloudFormation::Errors::ValidationError.new('a', 'b'))
      end

      it 'returns nil' do
        stack = StackMaster::Stack.find(region, stack_name)
        expect(stack).to be_nil
      end
    end

    context 'when CF returns no stacks' do
      before do
        cf.stub_responses(:describe_stacks, stacks: [])
      end

      it 'returns nil' do
        stack = StackMaster::Stack.find(region, stack_name)
        expect(stack).to be_nil
      end
    end
  end

  describe '.generate' do
    let(:tags) { { 'tag1' => 'value1' } }
    let(:stack_definition) { StackMaster::StackDefinition.new(region: region, stack_name: stack_name, tags: tags, base_dir: '/base_dir', template: template_file_name, notification_arns: ['test_arn'], role_arn: 'test_service_role_arn', stack_policy_file: 'no_replace_rds.json') }
    let(:config) { StackMaster::Config.new({'stacks' => {}}, '/base_dir') }
    subject(:stack) { StackMaster::Stack.generate(stack_definition, config) }
    let(:parameter_hash) { { 'DbPassword' => { 'secret' => 'db_password' } } }
    let(:resolved_parameters) { { 'DbPassword' => 'sdfgjkdhlfjkghdflkjghdflkjg', 'InstanceType' => 't2.medium' } }
    let(:template_file_name) { 'template.rb' }
    let(:template_body) { '{"Parameters": { "VpcId": { "Description": "VPC ID" }, "InstanceType": { "Description": "Instance Type", "Default": "t2.micro" }} }' }
    let(:template_format) { :json }
    let(:stack_policy_body) { '{}' }

    before do
      allow(StackMaster::ParameterLoader).to receive(:load).and_return(parameter_hash)
      allow(StackMaster::ParameterResolver).to receive(:resolve).and_return(resolved_parameters)
      allow(StackMaster::TemplateCompiler).to receive(:compile).with(config, stack_definition.template_file_path).and_return(template_body)
      allow(File).to receive(:read).with(stack_definition.stack_policy_file_path).and_return(stack_policy_body)
    end

    it 'has the stack definitions region' do
      expect(stack.region).to eq region
    end

    it 'has the stack definitions name' do
      expect(stack.stack_name).to eq stack_name
    end

    it 'has the stack definitions tags' do
      expect(stack.tags).to eq tags
    end

    it 'resolves the parameters' do
      expect(stack.parameters).to eq resolved_parameters
    end

    it 'compiles the template body' do
      expect(stack.template_body).to eq template_body
    end

    it 'has role_arn' do
      expect(stack.role_arn).to eq 'test_service_role_arn'
    end
    
    it 'has notification_arns' do
      expect(stack.notification_arns).to eq ['test_arn']
    end

    it 'has the stack policy' do
      expect(stack.stack_policy_body).to eq stack_policy_body
    end

    it 'extracts default template parameters' do
      expect(stack.template_default_parameters).to eq('VpcId' => nil, 'InstanceType' => 't2.micro')
    end

    it 'exposes parameters with defaults taken into account' do
      expect(stack.parameters_with_defaults).to eq('DbPassword' => 'sdfgjkdhlfjkghdflkjghdflkjg', 'InstanceType' => 't2.medium', 'VpcId' => nil)
    end
  end

  describe '#too_big?' do
    let(:big_stack) { described_class.new(template_body: "{\"a\":\"#{'x' * 500000}\"}") }
    let(:medium_stack) { described_class.new(template_body: "{\"a\":\"#{'x' * 60000}\"}") }
    let(:little_stack) { described_class.new(template_body: "{\"a\":\"#{'x' * 1000}\"}") }

    context 'when not using S3' do
      it 'returns true for big stacks' do
        expect(big_stack.too_big?).to be_truthy
      end
      it 'returns true for medium stacks' do
        expect(medium_stack.too_big?).to be_truthy
      end
      it 'returns false for small stacks' do
        expect(little_stack.too_big?).to be_falsey
      end
    end

    context 'when using S3' do
      it 'returns true for big stacks' do
        expect(big_stack.too_big?(true)).to be_truthy
      end
      it 'returns false for medium stacks' do
        expect(medium_stack.too_big?(true)).to be_falsey
      end
      it 'returns false for small stacks' do
        expect(little_stack.too_big?(true)).to be_falsey
      end
    end
  end

  describe '#missing_parameters?' do
    subject { stack.missing_parameters? }

    let(:stack) { StackMaster::Stack.new(parameters: parameters, template_body: '{}', template_format: :json) }

    context 'when a parameter has a nil value' do
      let(:parameters) { { 'my_param' => nil } }

      it { should eq true }
    end

    context 'when no parameers have a nil value' do
      let(:parameters) { { 'my_param' => '1' } }

      it { should eq false }
    end
  end
end
