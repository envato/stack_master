RSpec.describe StackMaster::Identity do
  let(:sts) { Aws::STS::Client.new(stub_responses: true) }
  subject(:identity) { StackMaster::Identity.new }

  before do
    allow(Aws::STS::Client).to receive(:new).and_return(sts)
  end

  describe '#running_in_allowed_account?' do
    let(:account) { '1234567890' }
    let(:running_in_allowed_account) { identity.running_in_allowed_account?(allowed_accounts) }

    before do
      allow(identity).to receive(:account).and_return(account)
    end

    context 'when allowed_accounts is nil' do
      let(:allowed_accounts) { nil }

      it 'returns true' do
        expect(running_in_allowed_account).to eq(true)
      end
    end

    context 'when allowed_accounts is an empty array' do
      let(:allowed_accounts) { [] }

      it 'returns true' do
        expect(running_in_allowed_account).to eq(true)
      end
    end

    context 'with an allowed account' do
      let(:allowed_accounts) { [account] }

      it 'returns true' do
        expect(running_in_allowed_account).to eq(true)
      end
    end

    context 'with no allowed account' do
      let(:allowed_accounts) { ['9876543210'] }

      it 'returns false' do
        expect(running_in_allowed_account).to eq(false)
      end
    end
  end

  describe '#account' do
    before do
      sts.stub_responses(:get_caller_identity, {
        account: 'account-id',
        arn: 'an-arn',
        user_id: 'a-user-id'
      })
    end

    it 'returns the current identity account' do
      expect(identity.account).to eq('account-id')
    end
  end
end
