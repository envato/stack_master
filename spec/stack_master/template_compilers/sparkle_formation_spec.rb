RSpec.describe StackMaster::TemplateCompilers::SparkleFormation do
  describe '.compile' do
    def compile
      described_class.compile(template_file_path)
    end

    before do
      allow(SparkleFormation).to receive(:compile).with(template_file_path).and_return({})
    end

    let(:template_file_path) { '/base_dir/templates/template.rb' }

    it 'compiles with sparkleformation' do
      expect(compile).to eq("{\n}")
    end

    it 'sets the appropriate sparkle_path' do
      compile
      expect(SparkleFormation.sparkle_path).to eq File.dirname(template_file_path)
    end
  end
end