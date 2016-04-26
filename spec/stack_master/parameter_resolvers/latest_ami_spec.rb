RSpec.describe StackMaster::ParameterResolvers::LatestAmi do
  let(:config) { double(base_dir: '/base') }
  let(:stack_definition) { double(stack_name: 'mystack', region: 'us-east-1') }
  subject(:resolver) { described_class.new(config, stack_definition) }
  let(:ec2) { Aws::EC2::Client.new }

  before do
    allow(Aws::EC2::Client).to receive(:new).and_return(ec2)
  end

  context 'when matches are found' do
    before do
      ec2.stub_responses(:describe_images, images: [
        { image_id: '1', creation_date: '2015-01-02 00:00:00', name: 'foo' },
        { image_id: '2', creation_date: '2015-01-03 00:00:00', name: 'foo' }
      ])
    end

    it 'returns the latest one' do
      expect(resolver.resolve('name=foo')).to eq '2'
    end
  end

  context 'when no matches are found' do
    before do
      ec2.stub_responses(:describe_images, images: [])
    end

    it 'returns nil' do
      expect(resolver.resolve('name=foo')).to be_nil
    end
  end
end
