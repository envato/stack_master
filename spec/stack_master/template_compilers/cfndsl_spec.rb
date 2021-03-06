RSpec.describe StackMaster::TemplateCompilers::Cfndsl do

  let(:compile_time_parameters) { {'InstanceType' => 't2.medium'} }

  before(:all) { described_class.require_dependencies }
  let(:template_dir) { 'spec/fixtures/templates/rb/cfndsl/' }

  describe '.compile' do
    def compile
      described_class.compile(template_dir, template, compile_time_parameters)
    end

    context 'valid cfndsl template' do
      let(:template) { 'sample.rb' }
      let(:valid_compiled_json_path) { 'spec/fixtures/templates/rb/cfndsl/sample.json' }

      it 'produces valid JSON' do
        valid_compiled_json = File.read(valid_compiled_json_path)
        expect(JSON.parse(compile)).to eq(JSON.parse(valid_compiled_json))
      end
    end

    context 'with compile time parameters' do
      let(:template) { 'sample-ctp.rb' }
      let(:valid_compiled_json_path) { 'spec/fixtures/templates/rb/cfndsl/sample-ctp.json' }

      it 'produces valid JSON' do
        valid_compiled_json = File.read(valid_compiled_json_path)
        expect(JSON.parse(compile)).to eq(JSON.parse(valid_compiled_json))
      end

      context 'compiling multiple times' do
        let(:compile_time_parameters) { {'InstanceType' => 't2.medium', 'DisableApiTermination' => 'true'} }
        let(:template) { 'sample-ctp-repeated.rb' }

        it 'does not leak compile time params across invocations' do
          expect {
            compile_time_parameters.delete("DisableApiTermination")
          }.to change { JSON.parse(compile)["Resources"]["MyInstance"]["Properties"]["DisableApiTermination"] }.from('true').to('false')
        end
      end
    end
  end
end
