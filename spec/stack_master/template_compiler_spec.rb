RSpec.describe StackMaster::TemplateCompiler do
  describe ".compile" do
    def compile
      StackMaster::TemplateCompiler.compile(template_file_path)
    end

    context 'json template' do
      let(:template_file_path) { '/base_dir/templates/template.json' }

      before do
        allow(File).to receive(:read).with(template_file_path).and_return('{ }')
      end

      it "reads from the template file path" do
        expect(compile).to eq('{}')
      end
    end

    context 'sparkleformation template' do
      let(:template_file_path) { '/base_dir/templates/template.rb' }

      before do
        allow(SparkleFormation).to receive(:compile).with(template_file_path).and_return({})
      end

      it 'compiles with sparkleformation' do
        expect(compile).to eq("{\n}")
      end

      it 'sets the appropriate sparkle_path' do
        compile
        expect(SparkleFormation.sparkle_path).to eq File.dirname(template_file_path)
      end
    end
  end
end
