RSpec.describe StackMaster::SsoGroupIdFinder do
  let(:region) { 'us-east-1' }
  let(:identity_store_id) { 'd-12345678' }
  let(:group_name) { 'AdminGroup' }
  let(:group_id) { 'abc-123-group-id' }

  let(:aws_client) { instance_double(Aws::IdentityStore::Client) }

  subject(:finder) do
    allow(Aws::IdentityStore::Client).to receive(:new).with(region: region).and_return(aws_client)
    described_class.new(region)
  end

  context 'when the group is found on the first page' do
    let(:response) do
      double(groups: [double(display_name: group_name, group_id: group_id)], next_token: nil)
    end

    it 'returns the group ID' do
      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50
      ).and_return(response)

      result = finder.find(group_name, identity_store_id)
      expect(result).to eq(group_id)
    end
  end

  context 'when the group is found on the second page' do
    let(:page_1) do
      double(groups: [double(display_name: 'OtherGroup', group_id: 'zzz')], next_token: 'page-2')
    end

    let(:page_2) do
      double(groups: [double(display_name: group_name, group_id: group_id)], next_token: nil)
    end

    it 'returns the group ID after paging' do
      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50
      ).and_return(page_1)

      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: 'page-2',
        max_results: 50
      ).and_return(page_2)

      result = finder.find(group_name, identity_store_id)
      expect(result).to eq(group_id)
    end
  end

  context 'when the group is not found after paging' do
    let(:page_1) do
      double(groups: [double(display_name: 'WrongGroup', group_id: 'aaa')], next_token: 'page-2')
    end

    let(:page_2) do
      double(groups: [double(display_name: 'AnotherWrongGroup', group_id: 'bbb')], next_token: nil)
    end

    it 'raises SsoGroupNotFound' do
      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50
      ).and_return(page_1)

      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: 'page-2',
        max_results: 50
      ).and_return(page_2)

      expect {
        finder.find(group_name, identity_store_id)
      }.to raise_error(StackMaster::SsoGroupIdFinder::SsoGroupNotFound, /No group with name #{group_name} found/)
    end
  end

  context 'when the reference is invalid' do
    it 'raises ArgumentError for nil' do
      expect {
        finder.find(nil, identity_store_id)
      }.to raise_error(ArgumentError, /SSO Group Name must be a non-empty string/)
    end

    it 'raises ArgumentError for empty string' do
      expect {
        finder.find('', identity_store_id)
      }.to raise_error(ArgumentError, /SSO Group Name must be a non-empty string/)
    end

    it 'raises ArgumentError for non-string type' do
      expect {
        finder.find(12345, identity_store_id)
      }.to raise_error(ArgumentError, /SSO Group Name must be a non-empty string/)
    end
  end

  context 'when AWS raises a service error' do
    let(:aws_error) { Aws::IdentityStore::Errors::ServiceError.new(nil, "AWS error") }

    it 'raises SsoGroupNotFound' do
      allow(aws_client).to receive(:list_groups).and_raise(aws_error)

      expect {
        finder.find(group_name, identity_store_id)
      }.to raise_error(StackMaster::SsoGroupIdFinder::SsoGroupNotFound, /No group with name #{group_name} found/)
    end
  end
end
