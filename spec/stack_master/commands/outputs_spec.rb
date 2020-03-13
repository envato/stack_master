RSpec.describe StackMaster::Commands::Outputs do
  subject(:outputs) { described_class.new(config, stack_definition) }

  let(:config) { spy(StackMaster::Config) }
  let(:stack_definition) { spy(StackMaster::StackDefinition, stack_name: 'mystack', region: 'us-east-1') }
  let(:stack) { spy(StackMaster::Stack, outputs: stack_outputs) }
  let(:stack_outputs) { double(:outputs) }

  before do
    allow(StackMaster::Stack).to receive(:find).and_return(stack)
    allow(outputs).to receive(:tp).and_return(spy)
  end

  describe '#perform' do
    subject(:perform) { outputs.perform }

    context 'given the stack exists' do
      it 'prints the details in a table form' do
        perform
        expect(outputs).to have_received(:tp).with(stack_outputs, :output_key, :output_value, :description)
      end

      specify 'the command is successful' do
        perform
        expect(outputs.success?).to be(true)
      end

      it 'makes the API call only once' do
        perform
        expect(StackMaster::Stack).to have_received(:find).with('us-east-1', 'mystack').once
      end
    end

    context 'given the stack does not exist' do
      before do
        allow(StackMaster::Stack).to receive(:find).and_return(nil)
      end

      specify 'the command is not successful' do
        perform
        expect(outputs.success?).to be(false)
      end
    end
  end
end
