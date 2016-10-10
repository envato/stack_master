RSpec.describe StackMaster::TemplateCompilers::Yaml do
  describe '.compile' do
    def compile
      described_class.compile(template_file_path)
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
