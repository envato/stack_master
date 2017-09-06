require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/parameter_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::ParameterValidator do

  describe '#validate' do

    let(:name) {'name'}

    subject {described_class.new(name, definition, parameter).validate}

    context 'with a :string type definition' do

      context 'with definition of {type: :string, multiple: true}' do

        let(:definition) {{type: :string, multiple: true}}

        context 'with parameter of "a"' do

          let(:parameter) {'a'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of "a,b"' do

          let(:parameter) {'a,b'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of nil' do

          let(:parameter) {nil}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name} cannot contain empty parameters:#{parameter.inspect}")
          end

        end

      end

      context 'with definition of type {type: :string, default: "a"}' do

        let(:definition) {{type: :string, default: 'a'}}

        context 'with parameter of "b"' do

          let(:parameter) {'b'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of nil' do

          let(:parameter) {nil}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

      end

      context 'with definition of type {type: :string, allowed_values: ["a"]}' do

        let(:definition) {{type: :string, allowed_values: ['a']}}

        context 'with parameter of "a"' do

          let(:parameter) {'a'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of "b"' do

          let(:parameter) {'b'}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:#{parameter} is not in allowed_values:#{definition[:allowed_values]}")
          end

        end

      end

      context 'with definition of type {type: :string, allowed_pattern: "^a"}' do

        let(:definition) {{type: :string, allowed_pattern: '^a'}}

        context 'with parameter of "a"' do

          let(:parameter) {'a'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of "b"' do

          let(:parameter) {'b'}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:[\"#{parameter}\"] does not match allowed_pattern:#{definition[:allowed_pattern]}")
          end

        end

      end

      context 'with definition of type {type: :string, min_size: 2}' do

        let(:definition) {{type: :string, min_size: 2}}

        context 'with parameter of "2"' do

          let(:parameter) {'2'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of "1"' do

          let(:parameter) {'1'}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:#{parameter} must not be less than min_size:#{definition[:min_size]}")
          end

        end


      end

      context 'with definition of type {type: :string, max_size: 2}' do

        let(:definition) {{type: :string, max_size: 2}}

        context 'with parameter of "2"' do

          let(:parameter) {'2'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of "3"' do

          let(:parameter) {'3'}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:#{parameter} must not be greater than max_size:#{definition[:max_size]}")
          end

        end


      end

      context 'with definition of type {type: :string, min_length: 2}' do

        let(:definition) {{type: :string, min_length: 2}}

        context 'with parameter of "ab"' do

          let(:parameter) {'ab'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of "a"' do

          let(:parameter) {'a'}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:#{parameter} must be at least min_length:#{definition[:min_length]} characters")
          end

        end

      end

      context 'with definition of type {type: :string, max_length: 2}' do

        let(:definition) {{type: :string, max_length: 2}}

        context 'with parameter of "ab"' do

          let(:parameter) {'ab'}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of "a"' do

          let(:parameter) {'abc'}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:#{parameter} must not exceed max_length:#{definition[:max_length]} characters")
          end

        end

      end

    end

    context 'with a :number type definition' do

      context 'with definition of {type: :number, multiple: true}' do

        let(:definition) {{type: :number, multiple: true}}

        context 'with parameter of 1' do

          let(:parameter) {1}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of [1,2]' do

          let(:parameter) {[1, 2]}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of nil' do

          let(:parameter) {nil}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name} cannot contain empty parameters:#{parameter.inspect}")
          end

        end

      end

      context 'with definition of type {type: :number, default: 1}' do

        let(:definition) {{type: :number, default: 1}}

        context 'with parameter of 1' do

          let(:parameter) {1}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of nil' do

          let(:parameter) {nil}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

      end

      context 'with definition of type {type: :number, allowed_values: [1]}' do

        let(:definition) {{type: :number, allowed_values: [1]}}

        context 'with parameter of 1' do

          let(:parameter) {1}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of 2' do

          let(:parameter) {2}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:#{parameter} is not in allowed_values:#{definition[:allowed_values]}")
          end

        end

      end

      context 'with definition of type {type: :number, min_size: 2}' do

        let(:definition) {{type: :number, min_size: 2}}

        context 'with parameter of 2' do

          let(:parameter) {2}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of 1' do

          let(:parameter) {1}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:#{parameter} must not be less than min_size:#{definition[:min_size]}")
          end

        end


      end

      context 'with definition of type {type: :number, man_size: 2}' do

        let(:definition) {{type: :number, max_size: 2}}

        context 'with parameter of 2' do

          let(:parameter) {2}

          it 'should not raise an exception' do
            expect {subject}.to_not raise_error
          end

        end

        context 'with parameter of 3' do

          let(:parameter) {3}

          it 'should raise an exception' do
            expect {subject}.to raise_error(ArgumentError, "Invalid compile time parameter: #{name}:#{parameter} must not be greater than max_size:#{definition[:max_size]}")
          end

        end

      end

    end

  end

end