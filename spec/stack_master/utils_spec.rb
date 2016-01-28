RSpec.describe StackMaster::Utils do
  describe ".hash_to_aws_tags" do
    let(:tags) { {'environment' => 'production'} }
    subject(:aws_tags) { StackMaster::Utils.hash_to_aws_tags(tags) }

    it "converts the tags attribute to aws format" do
      expect(aws_tags).to eq([{key: 'environment', value: 'production'}])
    end

    context "tags is nil" do
      let(:tags) { nil }

      it "returns nil" do
        expect(aws_tags).to eq([])
      end
    end
  end

  describe ".hash_to_aws_parameters" do
    let(:params) { { 'param1' => 'value1', 'param2' => 'value2', 'param3' => 3 } }
    subject(:aws_params) { StackMaster::Utils.hash_to_aws_parameters(params) }

    it "converts to aws parameters (numerics convert to strings)" do
      expect(aws_params).to eq([
        { parameter_key: 'param1', parameter_value: 'value1' },
        { parameter_key: 'param2', parameter_value: 'value2' },
        { parameter_key: 'param3', parameter_value: '3' }
      ])
    end
  end
end
