RSpec.describe StackMaster::Stack do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp_vpc' }
  let(:stack_id) { '1' }
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
        cf.stub_responses(:describe_stacks, stacks: [{ stack_id: stack_id, stack_name: stack_name, creation_time: Time.now, stack_status: 'UPDATE_COMPLETE', parameters: parameters}])
        cf.stub_responses(:get_template, template_body: "{}")
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
    let(:stack_definition) { StackMaster::Config::StackDefinition.new(region: region, stack_name: stack_name, tags: tags, base_dir: '/base_dir', template: template_file_name) }
    let(:config) { StackMaster::Config.new({'stacks' => {}}, '/base_dir') }
    subject(:stack) { StackMaster::Stack.generate(stack_definition, config) }
    let(:parameter_hash) { { 'db_password' => { 'secret' => 'db_password' } } }
    let(:resolved_parameters) { { 'db_password' => 'sdfgjkdhlfjkghdflkjghdflkjg' } }
    let(:template_file_name) { 'template.rb' }
    let(:template_body) { '{}' }

    before do
      allow(StackMaster::ParameterLoader).to receive(:load).and_return(parameter_hash)
      allow(StackMaster::ParameterResolver).to receive(:resolve).and_return(resolved_parameters)
      allow(StackMaster::TemplateCompiler).to receive(:compile).with(stack_definition.template_file_path).and_return(template_body)
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
  end
end
