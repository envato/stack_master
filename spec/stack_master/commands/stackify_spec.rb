RSpec.describe StackMaster::Commands::Stackify do
  let(:input_data) { File.read('spec/fixtures/templates/stackifier/cloudfront.json') }
  let(:expected)   { File.read('spec/fixtures/templates/stackifier/cloudfront.rb').gsub("\n","\n") }

  subject(:stackify) { described_class.perform(input_data) }

  describe '#perform' do
    it "generates a valid output" do
      expect(stackify.perform.join("\n")).to eq(expected)
    end
  end
end