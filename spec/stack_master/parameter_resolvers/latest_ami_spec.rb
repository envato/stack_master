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
      ec2.stub_responses(
        :describe_images,
        {
          images: [
            { image_id: '1', creation_date: '2015-01-02 00:00:00', name: 'foo' },
            { image_id: '2', creation_date: '2015-01-03 00:00:00', name: 'foo' }
          ]
        }
      )
    end

    it 'returns the latest one' do
      expect(resolver.resolve('filters' => { 'name' => 'foo' })).to eq '2'
    end
  end

  context 'when no matches are found' do
    before do
      ec2.stub_responses(:describe_images, { images: [] })
    end

    it 'returns nil' do
      expect(resolver.resolve('filters' => { 'name' => 'foo' })).to be_nil
    end
  end

  context 'when an owner_id is passed' do
    let(:ami_finder) { StackMaster::ParameterResolvers::AmiFinder.new('us-east-1') }
    before do
      expect(StackMaster::ParameterResolvers::AmiFinder).to receive(:new).and_return(ami_finder)
      allow(ami_finder).to receive(:build_filters_from_hash).and_call_original
    end

    it 'calls find_latest_ami with the owner and filters' do
      expect(ami_finder).to receive(:find_latest_ami).with([{ name: 'foo', values: ['bacon'] }], ['123456'])
      resolver.resolve({ 'owners' => 123_456, 'filters' => { 'foo' => 'bacon' } })
    end
  end
end
