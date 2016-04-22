RSpec.describe StackMaster::ParameterResolvers::AmiFinder do
  subject(:resolver) { described_class.new('us-east-1') }
  let(:ec2) { Aws::EC2::Client.new }
  let(:iam) { Aws::IAM::Client.new }

  before do
    allow(Aws::EC2::Client).to receive(:new).and_return(ec2)
    allow(Aws::IAM::Client).to receive(:new).and_return(iam)
    iam.stub_responses(:list_users, users: [
      {arn:"arn:aws:iam::012345678900:user/root", path: '/', user_name: 'root', user_id: '1', create_date: Time.now}
    ])
  end

  describe '#build_filters' do
    context 'when a single key-value pair is specified' do
      it 'returns an array with a single hash' do
        expect(resolver.build_filters('my-attr=my-value', nil)).to eq [
          { name: 'my-attr', values: ['my-value']}
        ]
      end
    end

    context 'when multiple key-value pairs are specified' do
      it 'returns an array with multiple hashes' do
        expect(resolver.build_filters('my-attr=my-value,foo=bar', nil)).to eq [
          { name: 'my-attr', values: ['my-value']},
          { name: 'foo', values: ['bar']}
        ]
      end
    end

    context 'when a prefix is supplied' do
      it 'adds the prefix to the filter' do
        expect(resolver.build_filters('my-tag=my-value', 'tag')).to eq [
          { name: 'tag:my-tag', values: ['my-value']}
        ]
      end
    end
  end

  describe '#find_latest_ami' do
    let(:filter) { [{ name: "String", values: ["String"]}] }

    context 'when matches are found' do
      before do
        ec2.stub_responses(:describe_images, images: [
          { image_id: '1', creation_date: '2015-01-02 00:00:00', tags: [{ key: 'my-tag', value: 'my-value' }] },
          { image_id: '2', creation_date: '2015-01-03 00:00:00', tags: [{ key: 'my-tag', value: 'my-value' }] }
        ])
      end

      it 'returns the latest one' do
        expect(resolver.find_latest_ami(filter).image_id).to eq '2'
      end
    end

    context 'when no matches are found' do
      before do
        ec2.stub_responses(:describe_images, images: [])
      end

      it 'returns nil' do
        expect(resolver.find_latest_ami(filter)).to be_nil
      end
    end
  end
end
