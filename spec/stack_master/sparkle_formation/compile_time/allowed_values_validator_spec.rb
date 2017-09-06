require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/allowed_values_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedValuesValidator do

  describe '#validate' do

    let(:name) {'name'}

    subject {described_class.new(name, definition, parameter).tap {|validator| validator.validate}}

    context 'with definition of type: :string' do

      context 'and multiple: true' do

        context 'and allowed values of ["a","b"]' do

          let(:definition) {{type: :string, multiple: true, allowed_values: %w(a b)}}

          ['a', 'a,b', 'a, b'].each do |parameter|

            context "and parameter is #{parameter.inspect}" do
              let(:parameter) {parameter}

              it ('should be valid') do
                expect(subject.is_valid).to be_truthy
              end

            end

          end

        end

        context 'and allowed values of ["c"]' do

          ['a', 'a,b', 'a, b'].each do |parameter|

            context "and parameter is #{parameter.inspect}" do

              let(:definition) {{type: :string, multiple: true, allowed_values: ['c']}}
              let(:parameter) {parameter}

              it ('should be not valid') do
                expect(subject.is_valid).to be_falsey
              end

              it ('should have an error message') do
                invalid_values = parameter.split(',').map(&:strip) - definition[:allowed_values]
                expect(subject.error).to eq "#{name}:#{invalid_values.join(',')} is not in allowed_values:#{definition[:allowed_values]}"
              end

            end
          end

          context 'and parameter is nil' do

            let(:parameter) {nil}

            context 'and default: of "c"' do
              let(:definition) {{type: :string, multiple: true, allowed_values: ['c'], default: 'c'}}

              it ('should be valid') do
                expect(subject.is_valid).to be_truthy
              end

            end

          end

        end

      end

      context 'and multiple: false' do

        context 'and allowed values of ["a","b"]' do

          let(:definition) {{type: :string, allowed_values: %w(a a,b)}}

          ['a', 'a,b', ['a']].each do |parameter|

            context "and parameter is #{parameter.inspect}" do
              let(:parameter) {parameter}

              it ('should be valid') do
                expect(subject.is_valid).to be_truthy
              end

            end

          end

        end

        context 'and allowed values of ["c"]' do

          ['a', 'a,b', %w(a b)].each do |parameter|

            context "and parameter is #{parameter.inspect}" do

              let(:definition) {{type: :string, allowed_values: ['c']}}
              let(:parameter) {parameter}

              it ('should be not valid') do
                expect(subject.is_valid).to be_falsey
              end

              it ('should have an error message') do
                error_parameters = parameter.is_a?(Array) ? parameter.join(',') : parameter
                expect(subject.error).to eq "#{name}:#{error_parameters} is not in allowed_values:#{definition[:allowed_values]}"
              end

            end
          end

          context 'and parameter is nil' do

            let(:parameter) {nil}

            context 'and default: of "c"' do
              let(:definition) {{type: :string, allowed_values: ['c'], default: 'c'}}

              it ('should be valid') do
                expect(subject.is_valid).to be_truthy
              end

            end

          end

        end

      end

    end

    context 'with definition of type: :number' do

      context 'and multiple: false' do

        context 'and allowed values of [1]' do

          let(:definition) {{type: :number, allowed_values: [1, 2]}}

          [1, [1, 2]].each do |parameter|

            context "and parameter is #{parameter.inspect}" do
              let(:parameter) {parameter}

              it ('should be valid') do
                expect(subject.is_valid).to be_truthy
              end

            end

          end

        end

        context 'and allowed values of [3]' do

          [1, [1, 2]].each do |parameter|

            context "and parameter is #{parameter.inspect}" do

              let(:definition) {{type: :string, allowed_values: [3, 4]}}
              let(:parameter) {parameter}

              it ('should be not valid') do
                expect(subject.is_valid).to be_falsey
              end

              it ('should have an error message') do
                error_parameters = parameter.is_a?(Array) ? parameter.join(',') : parameter
                expect(subject.error).to eq "#{name}:#{error_parameters} is not in allowed_values:#{definition[:allowed_values]}"
              end

            end
          end

          context 'and parameter is nil' do

            let(:parameter) {nil}

            context 'and default: of 1' do

              let(:definition) {{type: :number, allowed_values: [1], default: 1}}

              it ('should be valid') do
                expect(subject.is_valid).to be_truthy
              end

            end

          end

        end

      end

    end

  end

end