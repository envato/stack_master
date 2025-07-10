RSpec.describe StackMaster::ParameterResolvers::SsoGroupId do
  describe "#resolve" do
    let(:identity_store_id) { 'd-12345678' }
    let(:sso_group_id) { '64e804c8-8091-7093-3da9-123456789012' }
    let(:sso_group_name) { 'Okta-App-AWS-Group-Admin' }
    let(:region) { 'us-east-1' }

    let(:config) { instance_double('Config', sso_identity_store_id: identity_store_id) }
    let(:stack_definition) { instance_double('StackDefinition', region: region) }
    let(:finder) { instance_double(StackMaster::SsoGroupIdFinder) }

    subject(:resolver) { described_class.new(config, stack_definition) }

    before do
      allow(StackMaster::SsoGroupIdFinder).to receive(:new).with(region).and_return(finder)
      allow(finder).to receive(:find).with(sso_group_name, identity_store_id).and_return(sso_group_id)
    end

    context 'when given an SSO group name' do
      it "finds the sso group id" do
        expect(resolver.resolve(sso_group_name)).to eq sso_group_id
      end
    end

    context 'when sso_identity_store_id is missing' do
      let(:config) { instance_double('Config', sso_identity_store_id: nil) }

      it 'raises an InvalidParameter error' do
        expect {
          described_class.new(config, stack_definition)
        }.to raise_error(
          StackMaster::ParameterResolvers::SsoGroupId::InvalidParameter,
          /sso_identity_store_id must be set/
        )
      end
    end
  end
end
