RSpec.describe StackMaster::Commands::Resources do
  subject(:resources) { described_class.new(config, stack_definition) }

  let(:config) { spy(StackMaster::Config) }
  let(:stack_definition) { spy(StackMaster::StackDefinition, stack_name: 'mystack', region: 'us-east-1') }
  let(:cf) { spy(Aws::CloudFormation::Client, describe_stack_resources: stack_resources) }
  let(:stack_resources) { double(stack_resources: [stack_resource]) }
  let(:stack_resource) { double('stack_resource') }

  before do
    allow(Aws::CloudFormation::Client).to receive(:new).and_return(cf)
    allow(resources).to receive(:tp)
  end

  describe '#perform' do
    subject(:perform) { resources.perform }

    context 'given the stack exists' do
      it 'prints the details in a table form' do
        perform
        expect(resources).to have_received(:tp).with(
          [stack_resource], :logical_resource_id, :resource_type, :timestamp,
          :resource_status, :resource_status_reason, :description
        )
      end

      specify 'the command is successful' do
        perform
        expect(resources.success?).to be(true)
      end

      it 'makes the API call only once' do
        perform
        expect(cf).to have_received(:describe_stack_resources).with(stack_name: 'mystack').once
      end
    end

    context 'given the stack does not exist' do
      before do
        allow(cf).to receive(:describe_stack_resources).and_raise(Aws::CloudFormation::Errors::ValidationError.new('x',
                                                                                                                   'y'))
      end

      specify 'the command is not successful' do
        perform
        expect(resources.success?).to be(false)
      end
    end
  end
end
