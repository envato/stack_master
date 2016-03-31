RSpec.describe StackMaster::TemplateCompilers::Json do
  describe '.compile' do
    def compile
      described_class.compile(template_file_path)
    end

    let(:template_file_path) { '/base_dir/templates/template.json' }

    context "small json template" do
      before do
        allow(File).to receive(:read).with(template_file_path).and_return('{ }')
      end

      it "reads from the template file path" do
        expect(compile).to eq('{ }')
      end
    end

    context 'extra big json template' do
      before do
        allow(File).to receive(:read).with(template_file_path).and_return("{ #{' ' * 60000} }")
      end

      it "reads from the template file path" do
        expect(compile).to eq('{}')
      end
    end
  end
end