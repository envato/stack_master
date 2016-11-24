RSpec.describe StackMaster::TemplateUtils do
  describe "#maybe_compressed_template_body" do
    subject(:maybe_compressed_template_body) do
      described_class.maybe_compressed_template_body(template_body)
    end
    context "undersized json" do
      let(:template_body) { '{     }' }

      it "leaves the json alone if it's not too large" do
        expect(maybe_compressed_template_body).to eq('{     }')
      end
    end

    context "oversized json" do
      let(:template_body) { "{#{' ' * 60000}}" }
      it "compresses the json when it's overly bulbous" do
        expect(maybe_compressed_template_body).to eq('{}')
      end
    end
  end
end
