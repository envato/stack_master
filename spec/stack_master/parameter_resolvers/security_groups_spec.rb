require 'stack_master/parameter_resolvers/security_groups'

RSpec.describe StackMaster::ParameterResolvers::SecurityGroups do
  describe "#resolve" do
    subject(:resolver) { described_class.new(nil, double(region: 'us-east-1')) }
    let(:finder) { instance_double(StackMaster::SecurityGroupFinder) }
    let(:sg_id) { 'sg-id' }
    let(:sg_name) { 'sg-name' }

    before do
      allow(StackMaster::SecurityGroupFinder).to receive(:new).with('us-east-1').and_return finder
      expect(finder).to receive(:find).once.with(sg_name).and_return sg_id
    end

    context 'when given a single SG name' do
      it "resolves the security group" do
        expect(resolver.resolve(sg_name)).to eq [sg_id]
      end
    end

    context 'when given a an array of SG names' do
      let(:sg_id2) { 'sg-id2' }
      let(:sg_name2) { 'sg-name2' }

      before do
        expect(finder).to receive(:find).once.with(sg_name2).and_return sg_id2
      end

      it "resolves the security groups" do
        expect(resolver.resolve([sg_name, sg_name2])).to eq [sg_id, sg_id2]
      end
    end
  end
end
