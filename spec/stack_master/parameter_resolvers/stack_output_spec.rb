RSpec.describe StackMaster::ParameterResolvers::StackOutput do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'my-stack' }

  def resolve(value)
    described_class.new('us-east-1', value).resolve
  end

  subject(:resolved_value) { resolve(value) }

  context 'when given an invalid string value' do
    let(:value) { 'stack-name-without-output' }

    it 'raises an error' do
      expect {
        resolved_value
      }.to raise_error(ArgumentError)
    end
  end

  context 'when given a hash' do
    let(:value) { { not_expected: 1} }

    it 'raises an error' do
      expect {
        resolved_value
      }.to raise_error(ArgumentError)
    end
  end

  context 'when given a valid string value' do
    let(:value) { 'my-stack/MyOutput' }
    let(:stack) { double(outputs: outputs) }

    before do
      allow(StackMaster::Stack).to receive(:find).with(region, stack_name).and_return(stack)
    end

    context 'the stack and output exist' do
      let(:outputs) { [OpenStruct.new(output_key: 'MyOutput', output_value: 'myresolvedvalue')] }

      it 'resolves the value' do
        expect(resolved_value).to eq 'myresolvedvalue'
      end
    end

    context "the stack doesn't exist" do
      let(:stack) { nil }

      it 'resolves the value' do
        expect {
          resolved_value
        }.to raise_error(StackMaster::ParameterResolvers::StackOutput::StackNotFound)
      end
    end

    context "the output doesn't exist" do
      let(:outputs) { [] }

      it 'resolves the value' do
        expect {
          resolved_value
        }.to raise_error(StackMaster::ParameterResolvers::StackOutput::StackOutputNotFound)
      end
    end
  end
end
