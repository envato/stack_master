RSpec.describe StackMaster::TemplateCompilers::SparkleFormation do
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
