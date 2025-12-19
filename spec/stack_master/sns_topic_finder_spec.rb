RSpec.describe StackMaster::SnsTopicFinder do
  subject(:finder) { described_class.new(region) }
  let(:region) { 'us-east-1' }
  let(:topics) do
    [
      double(arn: 'arn:aws:sns:us-east-1:581634149801:topic1name'),
      double(arn: 'arn:aws:sns:us-east-1:581634149801:topic2name')
    ]
  end
  before do
    allow_any_instance_of(Aws::SNS::Resource).to receive(:topics).and_return topics
  end

  describe '#find' do
    it 'finds the topics that exist' do
      expect(finder.find('topic1name')).to eq 'arn:aws:sns:us-east-1:581634149801:topic1name'
      expect(finder.find('topic2name')).to eq 'arn:aws:sns:us-east-1:581634149801:topic2name'
    end

    it 'raises an exception for topics that do not exist' do
      expect { finder.find('unknowntopics') }.to raise_error StackMaster::SnsTopicFinder::TopicNotFound
    end
  end
end
