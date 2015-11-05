RSpec.describe StackMaster::StackDiffer do
  subject(:differ) { described_class.new(proposed_stack, stack) }
  let(:current_params) { Hash.new }
  let(:proposed_params) { { 'param1' => 'hello'} }
  let(:stack) { StackMaster::Stack.new(stack_name: stack_name,
                                       region: region,
                                       stack_id: 123,
                                       template_body: '{}',
                                       parameters: current_params) }
  let(:proposed_stack) { StackMaster::Stack.new(stack_name: stack_name,
                                                region: region,
                                                parameters: proposed_params,
                                                template_body: "{\"a\": 1}") }
  let(:stack_name) { 'myapp-vpc' }
  let(:region) { 'us-east-1' }

  describe "#proposed_parameters" do
    let(:current_params) { { 'param1' => 'hello',
                             'param2' => '****'} }
    it "stars out noecho params" do
      expect(differ.proposed_parameters).to eq "---\nparam1: hello\nparam2: \"****\"\n"
    end
  end

  describe "#output_diff" do
    context "entirely new stack" do
      let(:stack) { nil }

      it "outputs the entire stack" do
        expect { differ.output_diff }.to output(/\+  \"a\"\: 1/).to_stdout
        expect { differ.output_diff }.to output(/param1\: hello/).to_stdout
        expect { differ.output_diff }.to output(/No stack found/).to_stdout
      end
    end

    context "stack update" do
      it "outputs the stack diff" do
        expect { differ.output_diff }.to output(/\+  \"a\"\: 1/).to_stdout
        expect { differ.output_diff }.to output(/param1\: hello/).to_stdout
        expect { differ.output_diff }.to_not output(/No stack found/).to_stdout
      end
    end
  end
end
