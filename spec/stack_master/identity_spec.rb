RSpec.describe StackMaster::Identity do
  let(:sts) { Aws::STS::Client.new(stub_responses: true) }
  let(:iam) { Aws::IAM::Client.new(stub_responses: true) }

  subject(:identity) { StackMaster::Identity.new }

  before do
    allow(Aws::STS::Client).to receive(:new).and_return(sts)
    allow(Aws::IAM::Client).to receive(:new).and_return(iam)
  end

  describe '#running_in_account?' do
    let(:account) { '1234567890' }
    let(:running_in_allowed_account) { identity.running_in_account?(allowed_accounts) }

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

    describe 'with account aliases' do
      let(:account_aliases) { ['allowed-account'] }

      before do
        iam.stub_responses(:list_account_aliases, {
          account_aliases: account_aliases,
          is_truncated: false
        })
      end

      context "when it's allowed" do
        let(:allowed_accounts) { ['allowed-account'] }

        it 'returns true' do
          expect(running_in_allowed_account).to eq(true)
        end
      end

      context "when it's not allowed" do
        let(:allowed_accounts) { ['disallowed-account'] }

        it 'returns false' do
          expect(running_in_allowed_account).to eq(false)
        end
      end

      context 'with a combination of account id and alias' do
        let(:allowed_accounts) { %w(1928374 allowed-account another-account) }

        it 'returns true' do
          expect(running_in_allowed_account).to eq(true)
        end
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

  describe '#account_aliases' do
    before do
      iam.stub_responses(:list_account_aliases, {
        account_aliases: %w(my-account new-account-name),
        is_truncated: false
      })
    end

    it 'returns the current identity account aliases' do
      expect(identity.account_aliases).to eq(%w(my-account new-account-name))
    end

    context "when identity doesn't have the required iam permissions" do
      before do
        allow(iam).to receive(:list_account_aliases).and_raise(
          Aws::IAM::Errors.error_class('AccessDenied').new(
            an_instance_of(Seahorse::Client::RequestContext),
            'User: arn:aws:sts::123456789:assumed-role/my-role/987654321000 is not authorized to perform: iam:ListAccountAliases on resource: *'
          )
        )
      end

      it 'raises an error' do
        expect { identity.account_aliases }.to raise_error(
          StackMaster::Identity::MissingIamPermissionsError,
          'Failed to retrieve account aliases. Missing required IAM permission: iam:ListAccountAliases'
        )
      end
    end
  end
end
