RSpec.describe StackMaster::Stack do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp_vpc' }
  let(:stack_id) { '1' }
  let(:cf) { Aws::CloudFormation::Client.new }
  subject(:stack) { StackMaster::Stack.find(region, stack_name) }

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
  end

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
end
