RSpec.describe StackMaster::TemplateCompilers::Json do
  let(:config) { double(template_compilers: { fab: :test_template_compiler }) }
  let(:stack_definition) do
    StackMaster::StackDefinition.new(
      region: 'us-east-1',
      stack_name: 'myapp_vpc',
      template: 'myapp_vpc.json',
      tags: { 'environment' => 'production' },
      base_dir: File.expand_path('spec/fixtures'),
    )
  end
  describe '.compile' do
    def compile
      described_class.compile(config, template_file_path, stack_definition)
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
