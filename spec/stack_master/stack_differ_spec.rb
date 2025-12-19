RSpec.describe StackMaster::StackDiffer do
  subject(:differ) { described_class.new(proposed_stack, stack) }
  let(:current_body) { '{}' }
  let(:proposed_body) { "{\"a\": 1}" }
  let(:current_params) { Hash.new }
  let(:proposed_params) { { 'param1' => 'hello' } }
  let(:stack) do
    StackMaster::Stack.new(
      stack_name: stack_name,
      region: region,
      stack_id: 123,
      template_body: current_body,
      template_format: :json,
      parameters: current_params
    )
  end
  let(:proposed_stack) do
    StackMaster::Stack.new(
      stack_name: stack_name,
      region: region,
      parameters: proposed_params,
      template_body: proposed_body,
      template_format: :json
    )
  end
  let(:stack_name) { 'myapp-vpc' }
  let(:region) { 'us-east-1' }

  describe "#proposed_parameters" do
    let(:current_params) do
      {
        'param1' => 'hello',
        'param2' => '****'
      }
    end
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

  describe "#single_param_update?" do
    let(:yes_param) { 'YesParam' }
    let(:old_value) { 'old' }
    let(:new_value) { 'new' }
    let(:current_params) { { yes_param => old_value } }
    let(:proposed_params) { { yes_param => new_value } }
    let(:current_body) { proposed_body }

    subject(:result) { differ.single_param_update?(yes_param) }

    context "when only param changes" do
      it { is_expected.to be_truthy }
    end

    context "when new stack" do
      let(:stack) { nil }
      it { is_expected.to be_falsey }
    end

    context "when no changes" do
      let(:current_params) { proposed_params }
      it { is_expected.to be_falsey }
    end

    context "when body changes" do
      let(:current_body) { '{}' }
      it { is_expected.to be_falsey }
    end

    context "on param removal" do
      let(:proposed_params) { {} }
      it { is_expected.to be_falsey }
    end

    context "on param first addition" do
      let(:current_params) { {} }
      it { is_expected.to be_falsey }
    end

    context "when another param also changes" do
      let(:current_params) { { yes_param => old_value, 'other' => 'old' } }
      let(:proposed_params) { { yes_param => new_value, 'other' => 'new' } }
      it { is_expected.to be_falsey }
    end
  end
end
