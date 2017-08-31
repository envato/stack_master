require 'sparkle_formation'
RSpec.describe StackMaster::TemplateCompilers::SparkleFormation do

  describe '.compile' do
    def compile
      described_class.compile(template_file_path, nil, compiler_options)
    end

    before do
      allow(::SparkleFormation).to receive(:compile).with(template_file_path).and_return({})
    end

    let(:template_file_path) { '/base_dir/templates/template.rb' }
    let(:compiler_options) { {} }

    it 'compiles with sparkleformation' do
      expect(compile).to eq("{\n}")
    end

    it 'sets the appropriate sparkle_path' do
      compile
      expect(::SparkleFormation.sparkle_path).to eq File.dirname(template_file_path)
    end

    context 'with a custom sparkle_path' do
      let(:compiler_options)  { { "sparkle_path" => '../foo' } }

      it 'does not use the default path' do
        compile
        expect(::SparkleFormation.sparkle_path).to_not eq File.dirname(template_file_path)
      end

      it 'expands the given path' do
        compile
        expect(::SparkleFormation.sparkle_path).to match %r{^/.+/foo}
      end
    end
  end

  describe '.request_compile_parameter' do

    def compile_parameter(key, config, value)
      described_class.request_compile_parameter(key, config, value)
    end

    let(:key){'key'}

    context 'string compile time parameter' do

      context 'with default settings' do

        it 'should return the string value' do
          parameter = compile_parameter(key, {type: :string}, 'value')
          expect(parameter).to eq 'value'
        end

      end

      context 'with multiple true' do

        it 'should return the string value' do
          parameter = compile_parameter(key, {type: :string, multiple: true}, 'a,b')
          expect(parameter).to eq %w(a b)
        end

      end

      context 'with a default set' do

        context 'with a value of nil' do

          it 'should return the default value' do
            parameter = compile_parameter(key, {type: :string, default: 'a'}, nil)
            expect(parameter).to eq 'a'
          end


        end

        context 'with a value set' do

          it 'should return the value' do
            parameter = compile_parameter(key, {type: :string, default: 'a'}, 'b')
            expect(parameter).to eq 'b'
          end

        end


      end

    end

    context 'Number compile time parameter' do

      context 'with default settings' do

        it 'should return the string value' do
          parameter = compile_parameter(key, {type: :number}, '1')
          expect(parameter).to eq 1
        end

      end

      context 'with multiple true' do

        it 'should return the string value' do
          parameter = compile_parameter(key, {type: :number, multiple: true}, '1,2')
          expect(parameter).to eq [1,2]
        end

      end

      context 'with a default set' do

        context 'with a value of nil' do

          it 'should return the default value' do
            parameter = compile_parameter(key, {type: :number, default: 1}, nil)
            expect(parameter).to eq 1
          end


        end

        context 'with a value set' do

          it 'should return the value' do
            parameter = compile_parameter(key, {type: :number, default: 1}, 2)
            expect(parameter).to eq 2
          end

        end


      end

    end

  end
end
