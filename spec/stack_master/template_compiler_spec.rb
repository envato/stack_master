RSpec.describe StackMaster::TemplateCompiler do
  describe ".compile" do
    def compile
      StackMaster::TemplateCompiler.compile(template_file_path)
    end

    context 'json template' do
      let(:template_file_path) { '/base_dir/templates/template.json' }

      before do
        allow(File).to receive(:read).with(template_file_path).and_return('body')
      end

      it "reads from the template file path" do
        expect(compile).to eq('body')
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
    end
  end
end
