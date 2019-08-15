RSpec.describe StackMaster::TemplateCompilers::Yaml do
  describe '.compile' do

    let(:compile_time_parameters) { {'InstanceType' => 't2.medium'} }

    def compile
      described_class.compile(stack_definition, compile_time_parameters)
    end

    context 'valid YAML template' do
      let(:stack_definition) { instance_double(StackMaster::StackDefinition, template_file_path: template_file_path) }
      let(:template_file_path) { 'spec/fixtures/templates/yml/valid_myapp_vpc.yml' }

      it 'produces valid YAML' do
        valid_myapp_vpc_yaml = File.read(template_file_path)

        expect(compile).to eq(valid_myapp_vpc_yaml)
      end
    end
  end
end
