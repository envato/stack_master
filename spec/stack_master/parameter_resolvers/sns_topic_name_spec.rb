RSpec.describe StackMaster::ParameterResolvers::SnsTopicName do
  let(:region) { 'us-east-1' }
  let(:stack_name) { 'my-stack' }
  let(:config) { double }

  def resolve(value)
    described_class.new(config, double(region: 'us-east-1')).resolve(value)
  end

  subject(:resolved_value) { resolve(value) }

  context 'when given a hash' do
    let(:value) { { not_expected: 1 } }

    it 'raises an error' do
      expect {
        resolved_value
      }.to raise_error(ArgumentError)
    end
  end

  context 'when given a string value' do
    let(:value) { 'my-topic-name' }

    context 'the stack and sns topic name exist' do
      before do
        allow_any_instance_of(StackMaster::SnsTopicFinder).to receive(:find).with(value).and_return('myresolvedvalue')
      end

      it 'resolves the value' do
        expect(resolved_value).to eq 'myresolvedvalue'
      end
    end

    context "the topic doesn't exist" do
      it 'raises topic not found' do
        expect {
          resolved_value
        }.to raise_error(StackMaster::ParameterResolvers::SnsTopicName::TopicNotFound)
      end
    end
  end
end
