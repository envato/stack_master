require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/parameter_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::ParameterValidator do

  describe '#validate' do

    def validator(name, definition, parameter)
      described_class.new(name, definition, parameter).tap {|validator| validator.validate}
    end

    let(:name) {'name'}
    subject {validator(name, definition, parameter)}

    context 'with a :string type definition' do

      context 'with definition of {type: :string, multiple: true}' do

        let(:definition) {{type: :string, multiple: true}}

        context 'with parameter of "a"' do

          let(:parameter) {'a'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of "a,b"' do

          let(:parameter) {'a,b'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of nil' do

          let(:parameter) {nil}

          it 'should be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should have an error' do
            expect(subject.error).to eq "#{name} cannot be blank"
          end

        end

      end

      context 'with definition of type {type: :string, default: "a"}' do

        let(:definition) {{type: :string, default: 'a'}}

        context 'with parameter of "b"' do

          let(:parameter) {'b'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of nil' do

          let(:parameter) {nil}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

      end

      context 'with definition of type {type: :string, allowed_values: ["a"]}' do

        let(:definition) {{type: :string, allowed_values: ['a']}}

        context 'with parameter of "a"' do

          let(:parameter) {'a'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of "b"' do

          let(:parameter) {'b'}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} is not in allowed_values:#{definition[:allowed_values].join(',')}"
          end

        end

      end

      context 'with definition of type {type: :string, allowed_pattern: "^a"}' do

        let(:definition) {{type: :string, allowed_pattern: '^a'}}

        context 'with parameter of "a"' do

          let(:parameter) {'a'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of "b"' do

          let(:parameter) {'b'}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} does not match allowed_pattern:#{definition[:allowed_pattern]}"
          end

        end

      end

      context 'with definition of type {type: :string, min_size: 2}' do

        let(:definition) {{type: :string, min_size: 2}}

        context 'with parameter of "2"' do

          let(:parameter) {'2'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of "1"' do

          let(:parameter) {'1'}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} must not be less than min_size:#{definition[:min_size]}"
          end

        end


      end

      context 'with definition of type {type: :string, min_size: 2}' do

        let(:definition) {{type: :string, max_size: 2}}

        context 'with parameter of "2"' do

          let(:parameter) {'2'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of "3"' do

          let(:parameter) {'3'}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} must not be greater than max_size:#{definition[:max_size]}"
          end

        end


      end

      context 'with definition of type {type: :string, min_length: 2}' do

        let(:definition) {{type: :string, min_length: 2}}

        context 'with parameter of "ab"' do

          let(:parameter) {'ab'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of "a"' do

          let(:parameter) {'a'}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} must be at least min_length:#{definition[:min_length]} characters"
          end

        end

      end

      context 'with definition of type {type: :string, max_length: 2}' do

        let(:definition) {{type: :string, max_length: 2}}

        context 'with parameter of "ab"' do

          let(:parameter) {'ab'}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of "a"' do

          let(:parameter) {'abc'}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} must not exceed max_length:#{definition[:max_length]} characters"
          end

        end

      end

    end

    context 'with a :number type definition' do

      context 'with definition of {type: :number, multiple: true}' do

        let(:definition) {{type: :number, multiple: true}}

        context 'with parameter of 1' do

          let(:parameter) {1}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of [1,2]' do

          let(:parameter) {[1,2]}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of nil' do

          let(:parameter) {nil}

          it 'should be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should have an error' do
            expect(subject.error).to eq "#{name} cannot be blank"
          end

        end

      end

      context 'with definition of type {type: :number, default: 1}' do

        let(:definition) {{type: :number, default: 1}}

        context 'with parameter of 1' do

          let(:parameter) {1}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of nil' do

          let(:parameter) {nil}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

      end

      context 'with definition of type {type: :number, allowed_values: [1]}' do

        let(:definition) {{type: :number, allowed_values: [1]}}

        context 'with parameter of 1' do

          let(:parameter) {1}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of 2' do

          let(:parameter) {2}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} is not in allowed_values:#{definition[:allowed_values].join(',')}"
          end

        end

      end

      context 'with definition of type {type: :number, min_size: 2}' do

        let(:definition) {{type: :number, min_size: 2}}

        context 'with parameter of 2' do

          let(:parameter) {2}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of 1' do

          let(:parameter) {1}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} must not be less than min_size:#{definition[:min_size]}"
          end

        end


      end

      context 'with definition of type {type: :number, min_size: 2}' do

        let(:definition) {{type: :number, max_size: 2}}

        context 'with parameter of 2' do

          let(:parameter) {2}

          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end

          it 'should not have an error' do
            expect(subject.error).to be_nil
          end

        end

        context 'with parameter of 3' do

          let(:parameter) {3}

          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end

          it 'should not have an error' do
            expect(subject.error).to eq "#{name}:#{parameter} must not be greater than max_size:#{definition[:max_size]}"
          end

        end


      end

    end

  end

end