RSpec.describe StackMaster::StackDiffer do
  subject(:stack_master) { described_class.new(proposed_stack, stack) }
  let(:stack) { StackMaster::Stack.new(stack_name: stack_name,
                                       region: region,
                                       stack_id: 123,
                                       template_body: '{}',
                                       parameters: {}) }
  let(:proposed_stack) { StackMaster::Stack.new(stack_name: stack_name,
                                                region: region,
                                                parameters: { 'param1' => 'hello'},
                                                template_body: "{\"a\": 1}") }
  let(:stack_name) { 'myapp-vpc' }
  let(:region) { 'us-east-1' }

  describe "#perform" do
    context "entirely new stack" do
      let(:stack) { nil }

      it "outputs the entire stack" do
        expect { stack_master.perform }.to output(/\+  \"a\"\: 1/).to_stdout
        expect { stack_master.perform }.to output(/\+  \"param1\"\: \"hello\"/).to_stdout
        expect { stack_master.perform }.to output(/No stack found/).to_stdout
      end
    end

    context "stack update" do
      it "outputs the stack diff" do
        expect { stack_master.perform }.to output(/\+  \"a\"\: 1/).to_stdout
        expect { stack_master.perform }.to output(/\+  \"param1\"\: \"hello\"/).to_stdout
        expect { stack_master.perform }.to_not output(/No stack found/).to_stdout
      end
    end
  end
end
