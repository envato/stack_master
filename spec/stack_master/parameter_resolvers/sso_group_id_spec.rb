require 'spec_helper'

RSpec.describe StackMaster::ParameterResolvers::SsoGroupId do
  let(:config) { instance_double('Config') }
  let(:stack_definition) { instance_double('StackDefinition', region: 'us-east-1') }

  subject(:resolver) { described_class.new(config, stack_definition) }

  let(:group_reference) { 'us-east-1:d-12345678/AdminGroup' }
  let(:resolved_group_id) { 'abc-123-group-id' }
  let(:finder) { instance_double(StackMaster::SsoGroupIdFinder) }

  before do
    allow(StackMaster::SsoGroupIdFinder).to receive(:new).and_return(finder)
  end

  describe '#resolve' do
    context 'when group is found' do
      it 'returns the resolved group ID' do
        expect(finder).to receive(:find).with(group_reference).and_return(resolved_group_id)

        result = resolver.resolve(group_reference)
        expect(result).to eq(resolved_group_id)
      end
    end

    context 'when SsoGroupIdFinder raises an error' do
      it 'propagates the SsoGroupNotFound error' do
        allow(finder).to receive(:find).and_raise(StackMaster::SsoGroupIdFinder::SsoGroupNotFound)

        expect {
          resolver.resolve(group_reference)
        }.to raise_error(StackMaster::SsoGroupIdFinder::SsoGroupNotFound)
      end
    end

    context 'with invalid input' do
      let(:invalid_reference) { 'not/a/valid/reference' }

      it 'raises ArgumentError from SsoGroupIdFinder' do
        allow(finder).to receive(:find).and_raise(ArgumentError)

        expect {
          resolver.resolve(invalid_reference)
        }.to raise_error(ArgumentError)
      end
    end
  end
end
