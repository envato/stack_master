RSpec.describe StackMaster::SecurityGroupFinder do
  subject(:finder) { described_class.new(region) }
  let(:region) { 'us-east-1' }
  let(:group_name) { "our-api-BeanstalkSg-T4RKD99YOY2F" }
  let(:filter) do
    {
      filters: [
        {
          name: "group-name",
          values: [group_name],
        },
      ],
    }
  end

  describe "#find" do
    before do
      allow_any_instance_of(Aws::EC2::Resource).to receive(:security_groups).with(filter).and_return(security_groups)
    end

    context "one sg match" do
      let(:security_groups) {
        [
          double(id: 'sg-a7d2ccc0')
        ]
      }
      it "returns the id" do
        expect(finder.find(group_name)).to eq 'sg-a7d2ccc0'
      end
    end

    context "more than one sg matches" do
      let(:security_groups) {
        [
          double(id: 'sg-a7d2ccc0'),
          double(id: 'sg-a7d2ccc2'),
        ]
      }
      it "returns the id" do
        err = StackMaster::SecurityGroupFinder::MultipleSecurityGroupsFound
        expect { finder.find(group_name) }.to raise_error(err)
      end
    end

    context "no matches" do
      let(:security_groups) { [] }
      it "returns the id" do
        err = StackMaster::SecurityGroupFinder::SecurityGroupNotFound
        expect { finder.find(group_name) }.to raise_error(err)
      end
    end
  end
end
