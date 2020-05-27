RSpec.describe StackMaster::TemplateUtils do
  describe "#identify_template_format" do
    subject { described_class.identify_template_format(template_body) }

    context "with a json template body" do
      let(:template_body) { '{"AWSTemplateFormatVersion": "2010-09-09"}' }

      it { is_expected.to eq(:json) }
    end

    context "with a non-json template body" do
      let(:template_body) { 'AWSTemplateFormatVersion: 2010-09-09' }

        it { is_expected.to eq(:yaml) }
    end
  end

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
