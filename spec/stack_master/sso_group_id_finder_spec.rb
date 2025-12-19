require 'spec_helper'

RSpec.describe StackMaster::SsoGroupIdFinder do
  let(:group_name) { 'AdminGroup' }
  let(:identity_store_id) { 'd-12345678' }
  let(:region) { 'us-east-1' }
  let(:reference) { "#{region}:#{identity_store_id}/#{group_name}" }
  let(:aws_client) { instance_double(Aws::IdentityStore::Client) }

  subject(:finder) do
    allow(Aws::IdentityStore::Client).to receive(:new).with({ region: region }).and_return(aws_client)
    described_class.new
  end

  before do
    allow(StackMaster).to receive(:cloud_formation_driver).and_return(double(region: region))
  end

  describe '#find' do
    context 'when the group is found successfully' do
      it 'returns the group ID' do
        group_id = 'abc-123-group-id'

        response = double(group_id: group_id)
        expect(aws_client)
          .to receive(:get_group_id)
          .with(
            {
              identity_store_id: identity_store_id,
              alternate_identifier: {
                unique_attribute: {
                  attribute_path: 'displayName',
                  attribute_value: group_name
                }
              }
            }
          )
          .and_return(response)

        expect(finder.find(reference)).to eq(group_id)
      end
    end

    context 'when the group is not found' do
      it 'raises SsoGroupNotFound' do
        error = Aws::IdentityStore::Errors::ResourceNotFoundException.new(
          Seahorse::Client::RequestContext.new,
          "Group not found"
        )

        expect(aws_client).to receive(:get_group_id).and_raise(error)

        expect { finder.find(reference) }
          .to raise_error(StackMaster::SsoGroupIdFinder::SsoGroupNotFound, /No group with name #{group_name} found/)
      end
    end

    context 'when region is not provided in reference' do
      let(:reference_without_region) { "#{identity_store_id}/#{group_name}" }

      it 'uses the fallback region from cloud_formation_driver' do
        allow(Aws::IdentityStore::Client).to receive(:new).with({ region: region }).and_return(aws_client)

        group_id = 'fallback-region-group-id'
        response = double(group_id: group_id)

        expect(aws_client)
          .to receive(:get_group_id)
          .with(
            {
              identity_store_id: identity_store_id,
              alternate_identifier: {
                unique_attribute: {
                  attribute_path: 'displayName',
                  attribute_value: group_name
                }
              }
            }
          )
          .and_return(response)

        expect(finder.find(reference_without_region)).to eq(group_id)
      end
    end

    context 'when input is not a string' do
      it 'raises ArgumentError' do
        expect { finder.find(123) }
          .to raise_error(ArgumentError, /Sso group lookup parameter must be in the form/)
      end
    end

    context 'when input is an invalid string' do
      it 'raises ArgumentError' do
        invalid_reference = 'badformat'

        expect { finder.find(invalid_reference) }
          .to raise_error(ArgumentError, /Sso group lookup parameter must be in the form/)
      end
    end
  end
end
