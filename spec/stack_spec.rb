RSpec.describe StackMaster::Stack do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'myapp_vpc' }
  let(:stack_id) { '1' }
  let(:cf) { Aws::CloudFormation::Client.new }

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
  end

  context 'when the stack exists in AWS' do
    before do
      cf.stub_responses(:describe_stacks, stacks: [{ stack_id: stack_id, stack_name: stack_name, creation_time: Time.now, stack_status: 'UPDATE_COMPLETE'}])
    end

    it 'returns a stack object with a stack_id' do
      stack = StackMaster::Stack.find(region, stack_name)
      expect(stack.stack_id).to eq stack_id
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
