RSpec.describe StackMaster::TemplateCompilers::Yaml do
  describe '.compile' do
    def compile
      described_class.compile(template_file_path)
    end

    context 'valid YAML template' do
      let(:template_file_path) { 'spec/fixtures/templates/yml/valid_myapp_vpc.yml' }

      it 'produces valid JSON' do
        valid_myapp_vpc_as_json = File.read('spec/fixtures/templates/json/valid_myapp_vpc.json')
        expect(compile).to eq(valid_myapp_vpc_as_json)
      end
    end

    context 'invalid YAML template' do
      let(:template_file_path) { 'spec/fixtures/templates/yml/invalid_myapp_vpc.yml' }

      it 'returns an error' do
        expect(compile).to raise_error(StackMaster::TemplateCompilers::Yaml::CompileError)
      end
    end
  end
end