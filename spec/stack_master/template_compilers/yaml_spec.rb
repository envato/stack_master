RSpec.describe StackMaster::TemplateCompilers::Yaml do
  describe '.compile' do
    let(:compile_time_parameters) { { 'InstanceType' => 't2.medium' } }

    def compile
      described_class.compile(stack_definition.template_dir, stack_definition.template, compile_time_parameters)
    end

    context 'valid YAML template' do
      let(:stack_definition) do
        StackMaster::StackDefinition.new(template_dir: 'spec/fixtures/templates/yml',
                                         template: 'valid_myapp_vpc.yml')
      end

      it 'produces valid YAML' do
        valid_myapp_vpc_yaml = File.read(stack_definition.template_file_path)

        expect(compile).to eq(valid_myapp_vpc_yaml)
      end
    end
  end
end
