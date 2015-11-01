RSpec.describe StackMaster::StackDiffer do
  subject(:differ) { described_class.new(proposed_stack, stack) }
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

  describe "#output_diff" do
    context "entirely new stack" do
      let(:stack) { nil }

      it "outputs the entire stack" do
        expect { differ.output_diff }.to output(/\+  \"a\"\: 1/).to_stdout
        expect { differ.output_diff }.to output(/\+  \"param1\"\: \"hello\"/).to_stdout
        expect { differ.output_diff }.to output(/No stack found/).to_stdout
      end
    end

    context "stack update" do
      it "outputs the stack diff" do
        expect { differ.output_diff }.to output(/\+  \"a\"\: 1/).to_stdout
        expect { differ.output_diff }.to output(/\+  \"param1\"\: \"hello\"/).to_stdout
        expect { differ.output_diff }.to_not output(/No stack found/).to_stdout
      end
    end
  end
end
