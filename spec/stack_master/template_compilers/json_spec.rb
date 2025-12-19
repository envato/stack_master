RSpec.describe StackMaster::TemplateCompilers::Json do
  let(:compile_time_parameters) { { 'InstanceType' => 't2.medium' } }

  describe '.compile' do
    def compile
      described_class.compile(stack_definition.template_dir, stack_definition.template, compile_time_parameters)
    end

    let(:stack_definition) do
      StackMaster::StackDefinition.new(template_dir: File.dirname(template_file_path),
                                       template: File.basename(template_file_path))
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
