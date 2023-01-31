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
      ecr.stub_responses(
        :describe_images,
        {
          next_token: nil,
          image_details: [
            { registry_id: '012345678910', image_digest: 'sha256:decafc0ffee', image_pushed_at: Time.utc(2015,1,2,0,0), image_tags: ['v1'] },
            { registry_id: '012345678910', image_digest: 'sha256:deadbeef', image_pushed_at: Time.utc(2015,1,3,0,0), image_tags: ['v2'] }
          ]
        }
      )
    end

    it 'returns the latest one' do
      expect(resolver.resolve({'repository_name' => 'foo'})).to eq '012345678910.dkr.ecr.us-east-1.amazonaws.com/foo@sha256:deadbeef'
    end
  end

  context 'when no matches are found' do
    before do
      ecr.stub_responses(:describe_images, { next_token: nil, image_details: [] })
    end

    it 'returns nil' do
      expect(resolver.resolve({'repository_name' => 'foo'})).to be_nil
    end
  end

  context 'when a tag is passed in' do
    before do
      ecr.stub_responses(
        :describe_images,
        {
          next_token: nil,
          image_details: [
            { registry_id: '012345678910', image_digest: 'sha256:decafc0ffee', image_pushed_at: Time.utc(2015,1,2,0,0), image_tags: ['v1', 'production'] },
            { registry_id: '012345678910', image_digest: 'sha256:deadbeef', image_pushed_at: Time.utc(2015,1,3,0,0), image_tags: ['v2'] }
          ]
        }
      )
    end
  
    context 'when image exists' do
      it 'returns the image with the production tag' do
        expect(resolver.resolve({'repository_name' => 'foo', 'tag' => 'production'})).to eq '012345678910.dkr.ecr.us-east-1.amazonaws.com/foo@sha256:decafc0ffee'
      end
    end

    context 'when no image exists for this tag' do
      it 'returns nil' do
        expect(resolver.resolve({'repository_name' => 'foo', 'tag' => 'nosuchtag'})).to be_nil
      end
    end
  end

  context 'when registry_id is passed in' do
    before do
      ecr.stub_responses(
        :describe_images,
        {
          next_token: nil,
          image_details: [
            { registry_id: '012345678910', image_digest: 'sha256:decafc0ffee', image_pushed_at: Time.utc(2015,1,2,0,0), image_tags: ['v1'] },
          ]
        }
      )
    end

    it 'passes registry_id to describe_images' do
      expect(ecr).to receive(:describe_images).with({repository_name: "foo", registry_id: "012345678910", next_token: nil, filter: {:tag_status=>"TAGGED"}})
      resolver.resolve({'repository_name' => 'foo', 'registry_id' => '012345678910'})
    end
  end

  context 'when there are multiple pages' do
    before do
      ecr.stub_responses(:describe_images, [
        { next_token: '1', image_details: [
          { registry_id: '012345678910', image_digest: 'sha256:decafc0ffee', image_pushed_at: Time.utc(2015,1,2,0,0), image_tags: ['v1'] },
          { registry_id: '012345678910', image_digest: 'sha256:deadbeef', image_pushed_at: Time.utc(2015,1,3,0,0), image_tags: ['latest', 'v2'] }
        ]},
        { next_token: nil, image_details: [
          { registry_id: '012345678910', image_digest: 'sha256:badf00d', image_pushed_at: Time.utc(2015,1,4,0,0), image_tags: ['v3'] },
          { registry_id: '012345678910', image_digest: 'sha256:d15ea5e', image_pushed_at: Time.utc(2015,1,5,0,0), image_tags: ['v4'] }
        ]}
      ])
    end

    it 'takes all pages into account' do
      expect(resolver.resolve({'repository_name' => 'foo'})).to eq '012345678910.dkr.ecr.us-east-1.amazonaws.com/foo@sha256:d15ea5e'
    end
  end
end
