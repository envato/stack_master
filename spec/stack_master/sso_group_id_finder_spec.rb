require 'ostruct'

RSpec.describe StackMaster::SsoGroupIdFinder do
  let(:region) { 'us-east-1' }
  let(:identity_store_id) { 'd-12345678' }
  let(:group_name) { 'AdminGroup' }
  let(:group_id) { 'abc-123-group-id' }

  let(:aws_client) { instance_double(Aws::IdentityStore::Client) }

  subject(:finder) do
    # Avoid Ruby 3.x keyword arg stubbing issues
    allow(Aws::IdentityStore::Client).to receive(:new).and_return(aws_client)
    described_class.new(region)
  end

  context 'when the group is found on the first page' do
    let(:response) do
      OpenStruct.new(
        groups: [OpenStruct.new(display_name: group_name, group_id: group_id)],
        next_token: nil
      )
    end

    it 'returns the group ID immediately' do
      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50
      ).and_return(response)

      expect(finder.find(group_name, identity_store_id)).to eq(group_id)
    end
  end

  context 'when the group is found on the second page' do
    let(:page_1) do
      OpenStruct.new(
        groups: [OpenStruct.new(display_name: 'SomeOtherGroup', group_id: 'wrong-id')],
        next_token: 'next-token'
      )
    end

    let(:page_2) do
      OpenStruct.new(
        groups: [OpenStruct.new(display_name: group_name, group_id: group_id)],
        next_token: nil
      )
    end

    it 'finds the group after paging' do
      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50
      ).and_return(page_1)

      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: 'next-token',
        max_results: 50
      ).and_return(page_2)

      expect(finder.find(group_name, identity_store_id)).to eq(group_id)
    end
  end

  context 'when the group is not found after all pages' do
    let(:page_1) do
      OpenStruct.new(
        groups: [OpenStruct.new(display_name: 'Wrong1', group_id: 'id1')],
        next_token: 'token-2'
      )
    end

    let(:page_2) do
      OpenStruct.new(
        groups: [OpenStruct.new(display_name: 'Wrong2', group_id: 'id2')],
        next_token: nil
      )
    end

    it 'raises SsoGroupNotFound' do
      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50
      ).and_return(page_1)

      expect(aws_client).to receive(:list_groups).with(
        identity_store_id: identity_store_id,
        next_token: 'token-2',
        max_results: 50
      ).and_return(page_2)

      expect {
        finder.find(group_name, identity_store_id)
      }.to raise_error(StackMaster::SsoGroupIdFinder::SsoGroupNotFound, /No group with name #{group_name} found/)
    end
  end

  context 'when group name is invalid' do
    it 'raises ArgumentError for nil' do
      expect {
        finder.find(nil, identity_store_id)
      }.to raise_error(ArgumentError, /must be a non-empty string/)
    end

    it 'raises ArgumentError for empty string' do
      expect {
        finder.find('', identity_store_id)
      }.to raise_error(ArgumentError, /must be a non-empty string/)
    end
  end

  context 'when AWS raises a service error' do
    it 'prints an error and raises SsoGroupNotFound' do
      error = Aws::IdentityStore::Errors::ServiceError.new(
        Seahorse::Client::RequestContext.new,
        'Simulated AWS error'
      )

      allow(aws_client).to receive(:list_groups).and_raise(error)

      expect {
        finder.find(group_name, identity_store_id)
      }.to raise_error(StackMaster::SsoGroupIdFinder::SsoGroupNotFound)
    end
  end
end
