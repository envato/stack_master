RSpec.describe StackMaster::Commands::Delete do

  subject(:delete) { described_class.new(stack_name, region, options) }
  let(:cf) { spy(Aws::CloudFormation::Client.new) }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'mystack' }
  let(:options) { Commander::Command::Options.new }

  before do
    StackMaster.cloud_formation_driver.set_region(region)
    allow(Aws::CloudFormation::Client).to receive(:new).with({ region: region, retry_limit: 10 }).and_return(cf)
    allow(delete).to receive(:ask?).and_return('y')
    allow(StackMaster::StackEvents::Streamer).to receive(:stream)
  end

  describe "#perform" do
    context "The stack exists" do
      before do
        allow(cf).to receive(:describe_stacks).and_return(
          {stacks: [{ stack_id: "ABC", stack_name: stack_name, creation_time: Time.now, stack_status: 'UPDATE_COMPLETE', parameters: []}]}
        )
      end
      it "deletes the stack and tails the events" do
        delete.perform
        expect(cf).to have_received(:delete_stack).with({:stack_name => region})
        expect(StackMaster::StackEvents::Streamer).to have_received(:stream)
      end
    end

    context "The stack does not exist" do
      before do
        allow(cf).to receive(:describe_stacks).and_raise(Aws::CloudFormation::Errors::ValidationError.new("x", "y"))
      end
      it "is not successful" do
        delete.perform
        expect(StackMaster::StackEvents::Streamer).not_to have_received(:stream)
        expect(cf).not_to have_received(:delete_stack)
        expect(delete.success?).to be false
      end
    end
  end

end
