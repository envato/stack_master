RSpec.describe StackMaster::ParameterResolvers::LatestContainer do
  let(:config) { double(base_dir: '/base') }
  let(:stack_definition) { double(stack_name: 'mystack', region: 'us-east-1') }
  subject(:resolver) { described_class.new(config, stack_definition) }
  let(:ecr) { Aws::ECR::Client.new(stub_responses: true) }

  before do
    allow(Aws::ECR::Client).to receive(:new).and_return(ecr)
  end

  context 'when matches are found' do
    before do
      ecr.stub_responses(:describe_images, next_token: nil, image_details: [
        { registry_id: '012345678910', image_digest: 'decafc0ffee', image_pushed_at: Time.utc(2015,1,2,0,0), image_tags: ['v1'] },
        { registry_id: '012345678910', image_digest: 'deadbeef', image_pushed_at: Time.utc(2015,1,3,0,0), image_tags: ['v2'] }
      ])
    end

    it 'returns the latest one' do
      expect(resolver.resolve({'repository_name' => 'foo'})).to eq '012345678910.dkr.ecr.us-east-1.amazonaws.com/foo:v2'
    end
  end

  context 'when there are multiple tags including latest' do
    before do
      ecr.stub_responses(:describe_images, next_token: nil, image_details: [
        { registry_id: '012345678910', image_digest: 'decafc0ffee', image_pushed_at: Time.utc(2015,1,2,0,0), image_tags: ['v1'] },
        { registry_id: '012345678910', image_digest: 'deadbeef', image_pushed_at: Time.utc(2015,1,3,0,0), image_tags: ['latest', 'v2'] }
      ])
    end

    it 'does not return the latest tag' do
      expect(resolver.resolve({'repository_name' => 'foo'})).to eq '012345678910.dkr.ecr.us-east-1.amazonaws.com/foo:v2'
    end
  end

  context 'when no matches are found' do
    before do
      ecr.stub_responses(:describe_images, next_token: nil, image_details: [])
    end

    it 'returns nil' do
      expect(resolver.resolve({'repository_name' => 'foo'})).to be_nil
    end
  end

  context 'when registry_id is passed in' do
    before do
      ecr.stub_responses(:describe_images, next_token: nil, image_details: [
        { registry_id: '012345678910', image_digest: 'decafc0ffee', image_pushed_at: Time.utc(2015,1,2,0,0), image_tags: ['v1'] },
      ])
    end

    it 'passes registry_id to describe_images' do
      expect(ecr).to receive(:describe_images).with(repository_name: "foo", registry_id: "012345678910", next_token: nil)
      resolver.resolve({'repository_name' => 'foo', 'registry_id' => '012345678910'})
    end
  end

  context 'when there are multiple pages' do
    before do
      ecr.stub_responses(:describe_images, [
        { next_token: '1', image_details: [
          { registry_id: '012345678910', image_digest: 'decafc0ffee', image_pushed_at: Time.utc(2015,1,2,0,0), image_tags: ['v1'] },
          { registry_id: '012345678910', image_digest: 'deadbeef', image_pushed_at: Time.utc(2015,1,3,0,0), image_tags: ['latest', 'v2'] }
        ]},
        { next_token: nil, image_details: [
          { registry_id: '012345678910', image_digest: 'decafc0ffee', image_pushed_at: Time.utc(2015,1,4,0,0), image_tags: ['v3'] },
          { registry_id: '012345678910', image_digest: 'deadbeef', image_pushed_at: Time.utc(2015,1,5,0,0), image_tags: ['v4'] }
        ]}
      ])
    end

    it 'takes all pages into account' do
      expect(resolver.resolve({'repository_name' => 'foo'})).to eq '012345678910.dkr.ecr.us-east-1.amazonaws.com/foo:v4'
    end
  end
end
