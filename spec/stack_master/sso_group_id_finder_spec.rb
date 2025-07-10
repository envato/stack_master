require 'ostruct'

RSpec.describe StackMaster::SsoGroupIdFinder do
  let(:identity_store_id) { 'd-12345678' }
  let(:group_name) { 'AdminGroup' }
  let(:group_id) { 'abc-123-group-id' }
  let(:region) { 'us-east-1' }
  let(:reference) { "#{region}:#{identity_store_id}/#{group_name}" }

  let(:aws_client) { instance_double(Aws::IdentityStore::Client) }

  subject(:finder) do
    allow(Aws::IdentityStore::Client).to receive(:new).and_return(aws_client)
    described_class.new
  end

  before do
    # Stub StackMaster.cloud_formation_driver.region
    allow(StackMaster).to receive(:cloud_formation_driver).and_return(double(region: region))
  end

  context 'when group is found on first page' do
    it 'returns the group ID' do
      page = OpenStruct.new(
        groups: [OpenStruct.new(display_name: group_name, group_id: group_id)],
        next_token: nil
      )

      expect(aws_client).to receive(:list_groups).with({
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50}
      ).and_return(page)

      expect(finder.find(reference)).to eq(group_id)
    end
  end

  context 'when region is omitted' do
    let(:reference) { "#{identity_store_id}/#{group_name}" }

    it 'uses region from StackMaster.cloud_formation_driver' do
      page = OpenStruct.new(
        groups: [OpenStruct.new(display_name: group_name, group_id: group_id)],
        next_token: nil
      )

      expect(aws_client).to receive(:list_groups).with({
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50}
      ).and_return(page)

      expect(finder.find(reference)).to eq(group_id)
    end
  end

  context 'when group is found on second page' do
    it 'paginates and returns the group ID' do
      page1 = OpenStruct.new(
        groups: [OpenStruct.new(display_name: 'OtherGroup', group_id: 'wrong')],
        next_token: 'next123'
      )

      page2 = OpenStruct.new(
        groups: [OpenStruct.new(display_name: group_name, group_id: group_id)],
        next_token: nil
      )

      expect(aws_client).to receive(:list_groups).with({
        identity_store_id: identity_store_id,
        next_token: nil,
        max_results: 50}
      ).and_return(page1)

      expect(aws_client).to receive(:list_groups).with({
        identity_store_id: identity_store_id,
        next_token: 'next123',
        max_results: 50}
      ).and_return(page2)

      expect(finder.find(reference)).to eq(group_id)
    end
  end

  context 'when no matching group is found' do
    it 'raises SsoGroupNotFound' do
      page = OpenStruct.new(
        groups: [OpenStruct.new(display_name: 'WrongGroup', group_id: 'x')],
        next_token: nil
      )

      expect(aws_client).to receive(:list_groups).and_return(page)

      expect {
        finder.find(reference)
      }.to raise_error(StackMaster::SsoGroupIdFinder::SsoGroupNotFound, /No group with name #{group_name} found/)
    end
  end

  context 'when input format is invalid' do
    it 'raises ArgumentError for blank string' do
      expect {
        finder.find('')
      }.to raise_error(ArgumentError, /Sso group lookup parameter must be/)
    end

    it 'raises ArgumentError for missing slash' do
      expect {
        finder.find('region:storeid-and-no-group')
      }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError for non-string input' do
      expect {
        finder.find(12345)
      }.to raise_error(ArgumentError)
    end
  end

  context 'when AWS service raises an error' do
    it 'logs and raises SsoGroupNotFound' do
      aws_error = Aws::IdentityStore::Errors::ServiceError.new(
        Seahorse::Client::RequestContext.new, 'AWS failure'
      )

      allow(aws_client).to receive(:list_groups).and_raise(aws_error)

      expect {
        finder.find(reference)
      }.to raise_error(StackMaster::SsoGroupIdFinder::SsoGroupNotFound)
    end
  end
end
