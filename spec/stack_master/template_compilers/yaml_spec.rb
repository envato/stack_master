RSpec.describe StackMaster::TemplateCompilers::Yaml do
  describe '.compile' do

    let(:compile_time_parameters) { {'InstanceType' => 't2.medium'} }

    def compile
      described_class.compile(template_file_path, compile_time_parameters)
    end

    context 'valid YAML template' do
      let(:template_file_path) { 'spec/fixtures/templates/yml/valid_myapp_vpc.yml' }

      it 'produces valid YAML' do
        valid_myapp_vpc_yaml = File.read('spec/fixtures/templates/yml/valid_myapp_vpc.yml')

        expect(compile).to eq(valid_myapp_vpc_yaml)
      end
    end
  end
end
