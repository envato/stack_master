require 'sparkle_formation'
RSpec.describe StackMaster::TemplateCompilers::SparkleFormation do

  describe '.compile' do
    def compile
      described_class.compile(template_file_path, nil, compiler_options)
    end

    let(:template_file_path) {'/base_dir/templates/template.rb'}
    let(:compiler_options) {{}}
    let(:sparkle_template) {instance_double(::SparkleFormation)}
    before do
      allow(::SparkleFormation).to receive(:compile).with(template_file_path, :sparkle).and_return(sparkle_template)
      allow(sparkle_template).to receive(:compile_time_parameter_setter)
      allow(JSON).to receive(:pretty_generate).with(sparkle_template).and_return("{\n}")
    end


    it 'compiles with sparkleformation' do
      expect(compile).to eq("{\n}")
    end

    it 'sets the appropriate sparkle_path' do
      compile
      expect(::SparkleFormation.sparkle_path).to eq File.dirname(template_file_path)
    end

    context 'with a custom sparkle_path' do
      let(:compiler_options) {{"sparkle_path" => '../foo'}}

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

  describe '.create_compile_parameter' do

    def compile_parameter(key, config, value)
      described_class.create_compile_parameter(key, config, value)
    end

    let(:key) {'key'}

    context 'with string compile time parameter' do

      let(:type) {:string}

      context 'with default settings' do

        it 'should return the string value' do
          parameter = compile_parameter(key, {type: type}, 'value')
          expect(parameter).to eq 'value'
        end

      end

      context 'with multiple true' do

        it 'should return the string value' do
          parameter = compile_parameter(key, {type: type, multiple: true}, 'a,b')
          expect(parameter).to eq %w(a b)
        end

      end

      context 'with a default set' do

        context 'with a value of nil' do

          it 'should return the default value' do
            parameter = compile_parameter(key, {type: type, default: 'a'}, nil)
            expect(parameter).to eq 'a'
          end


        end

        context 'with a value set' do

          it 'should return the value' do
            parameter = compile_parameter(key, {type: type, default: 'a'}, 'b')
            expect(parameter).to eq 'b'
          end

        end


      end

      context 'with allowed_values set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, allowed_values: ['a']}, 'a')
          expect(parameter).to eq 'a'
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, allowed_values: ['a']}, 'b')}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:b is not in allowed_values:a")
        end

      end

      context 'with allowed_pattern set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, allowed_pattern: '^a'}, 'a')
          expect(parameter).to eq 'a'
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, allowed_pattern: '$b'}, 'a')}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:a does not match allowed_pattern:$b")
        end
      end

      context 'with min_size set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, min_size: 2}, '2')
          expect(parameter).to eq '2'
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, min_size: 2}, '1')}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:1 must not be less than min_size:2")
        end

      end

      context 'with max_size set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, max_size: 2}, '2')
          expect(parameter).to eq '2'
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, max_size: 2}, '3')}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:3 must not be greater than max_size:2")
        end

      end

      context 'with min_length set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, min_length: 2}, 'ab')
          expect(parameter).to eq 'ab'
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, min_length: 2}, 'a')}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:a must be at least min_length:2 characters")
        end

      end

      context 'with max_length set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, max_length: 2}, 'ab')
          expect(parameter).to eq 'ab'
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, min_length: 2}, 'a')}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:a must be at least min_length:2 characters")
        end

      end


    end

    context 'with number compile time parameter' do

      let(:type) {:number}

      context 'with default settings' do

        it 'should return the string value' do
          parameter = compile_parameter(key, {type: type}, '1')
          expect(parameter).to eq 1
        end

      end

      context 'with multiple true' do

        it 'should return the string value' do
          parameter = compile_parameter(key, {type: type, multiple: true}, '1,2')
          expect(parameter).to eq [1, 2]
        end

      end

      context 'with a default set' do

        context 'with a value of nil' do

          it 'should return the default value' do
            parameter = compile_parameter(key, {type: type, default: 1}, nil)
            expect(parameter).to eq 1
          end


        end

        context 'with a value set' do

          it 'should return the value' do
            parameter = compile_parameter(key, {type: type, default: 1}, 2)
            expect(parameter).to eq 2
          end

        end

      end

      context 'with allowed_values set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, allowed_values: [1]}, 1)
          expect(parameter).to eq 1
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, allowed_values: [1]}, 2)}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:2 is not in allowed_values:1")
        end

      end

      context 'with min_size set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, min_size: 2}, 2)
          expect(parameter).to eq 2
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, min_size: 2}, 1)}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:1 must not be less than min_size:2")
        end

      end

      context 'with max_size set' do

        it 'should not raise an exception with valid values' do
          parameter = compile_parameter(key, {type: type, max_size: 2}, 2)
          expect(parameter).to eq 2
        end

        it 'should raise an exception with invalid values' do
          expect {compile_parameter(key, {type: type, max_size: 2}, 3)}
              .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:3 must not be greater than max_size:2")
        end

      end
    end

    context 'with multiple invalid compile time parameters' do
      it 'should raise one exception with multiple invalid messages ' do
        expect {compile_parameter(key, {type: :number, max_size: 2, allowed_values: [1]}, 3)}
            .to raise_error(ArgumentError, "Invalid compile time parameter: #{key}:3 is not in allowed_values:1")
      end

    end

    context 'with other type' do

      let(:type) {:blah}

      it 'should raise an exception' do
        expect {compile_parameter(key, {type: type}, nil)}
            .to raise_error(ArgumentError, "Unknown compile time parameter type: #{key}:#{type} valid types are #{[:string, :number].pretty_inspect}")
      end


    end

  end
end
