RSpec.describe StackMaster::TemplateCompilers::Cfndsl do

  let(:compile_time_parameters) { {'InstanceType' => 't2.medium'} }

  before(:all) { described_class.require_dependencies }

  describe '.compile' do
    def compile
      described_class.compile(template_file_path, compile_time_parameters)
    end

    context 'valid cfndsl template' do
      let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample.rb' }
      let(:valid_compiled_json_path) { 'spec/fixtures/templates/rb/cfndsl/sample.json' }

      it 'produces valid JSON' do
        valid_compiled_json = File.read(valid_compiled_json_path)
        expect(JSON.parse(compile)).to eq(JSON.parse(valid_compiled_json))
      end
    end

    context 'with compile time parameters' do
      let(:template_file_path) { 'spec/fixtures/templates/rb/cfndsl/sample-ctp.rb' }
      let(:valid_compiled_json_path) { 'spec/fixtures/templates/rb/cfndsl/sample-ctp.json' }

      it 'produces valid JSON' do
        valid_compiled_json = File.read(valid_compiled_json_path)
        expect(JSON.parse(compile)).to eq(JSON.parse(valid_compiled_json))
      end
    end
  end
end
