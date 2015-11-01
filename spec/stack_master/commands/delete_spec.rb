RSpec.describe StackMaster::Commands::Delete do

  subject(:delete) { described_class.new(nil, stack_name, region) }
  let(:cf) { Aws::CloudFormation::Client.new }
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'mystack' }

  before do
    StackMaster.cloud_formation_driver.set_region(region)
    allow(Aws::CloudFormation::Client).to receive(:new).with(region: region).and_return(cf)
    allow(delete).to receive(:ask?).and_return('y')
    allow(StackMaster::StackEvents::Streamer).to receive(:stream)
  end

  describe "#perform" do
    context "The stack exists" do
      before do
        cf.stub_responses(:describe_stacks, stacks: [{ stack_id: "ABC", stack_name: stack_name, creation_time: Time.now, stack_status: 'UPDATE_COMPLETE', parameters: []}])

      end
      it "deletes the stack and tails the events" do
        expect(cf).to receive(:delete_stack).with({:stack_name => region})
        expect(StackMaster::StackEvents::Streamer).to receive(:stream)
        delete.perform
      end
    end

    context "The stack does not exist" do
      before do
        cf.stub_responses(:describe_stacks, Aws::CloudFormation::Errors::ValidationError.new("x", "y"))
      end
      it "raises an error" do
        expect(StackMaster::StackEvents::Streamer).to_not receive(:stream)
        expect(cf).to_not receive(:delete_stack)
        delete.perform
      end
    end
  end

end
