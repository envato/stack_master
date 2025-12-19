RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedValuesValidator do
  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) do
      lambda { |error, definition|
        "#{name}:#{error} is not in allowed_values:#{definition[:allowed_values]}"
      }
    end

    context 'string validation' do
      let(:definition) { { type: :string, allowed_values: ['a'] } }
      validate_valid_parameter('a')
      validate_valid_parameter(['a'])
      validate_invalid_parameter('b', ['b'])
      validate_invalid_parameter(['b'], ['b'])
    end

    context 'string validation with default' do
      let(:definition) { { type: :string, allowed_values: ['a'], default: 'a' } }
      validate_valid_parameter(nil)
    end

    context 'string validation with multiple' do
      let(:definition) { { type: :string, allowed_values: ['a'], multiple: true } }
      validate_valid_parameter('a,a')
      validate_invalid_parameter('a,, a', [''])
      validate_invalid_parameter('a,,b', ['', 'b'])
    end

    context 'string validation with multiple default values' do
      let(:definition) { { type: :string, allowed_values: ['a'], multiple: true, default: 'a,a' } }
      validate_valid_parameter(nil)
    end

    context 'numerical validation' do
      let(:definition) { { type: :number, allowed_values: [1] } }
      validate_valid_parameter(1)
      validate_valid_parameter('1')
      validate_valid_parameter([1])
      validate_valid_parameter(['1'])
      validate_invalid_parameter(2, [2])
      validate_invalid_parameter('2', ['2'])
    end

    context 'numerical validation with default value' do
      let(:definition) { { type: :number, allowed_values: [1], default: 1 } }
      validate_valid_parameter(nil)
    end
  end
end
