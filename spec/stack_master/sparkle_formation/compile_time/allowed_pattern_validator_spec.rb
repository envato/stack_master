RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedPatternValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, definition) { "#{name}:#{error} does not match allowed_pattern:#{definition[:allowed_pattern]}" } }

    context 'string validation' do
      let(:definition) { {type: :string, allowed_pattern: '^a'} }
      validate_valid_parameter('a')
      validate_valid_parameter(['a'])
      validate_invalid_parameter('b', ['b'])
      validate_invalid_parameter(['b'], ['b'])
    end

    context 'string validation with default' do
      let(:definition) { {type: :string, allowed_pattern: '^a', default: 'a'} }
      validate_valid_parameter(nil)
    end

    context 'string validation with multiple' do
      let(:definition) { {type: :string, allowed_pattern: '^a', multiple: true} }
      validate_valid_parameter('a,ab')
      validate_invalid_parameter('a,,ab', [''])
      validate_invalid_parameter('a, ,ab', [''])
    end

    context 'string validation with multiple default values' do
      let(:definition) { {type: :string, allowed_pattern: '^a', multiple: true, default:'a,a'} }
      validate_valid_parameter(nil)
    end

    context 'numerical validation' do
      let(:definition) { {type: :number, allowed_pattern: '^1'} }
      validate_valid_parameter(1)
      validate_valid_parameter('1')
      validate_valid_parameter([1])
      validate_valid_parameter(['1'])
      validate_invalid_parameter(2, [2])
      validate_invalid_parameter('2', ['2'])
    end

    context 'validation with default value' do
      let(:definition) { {type: :number, allowed_pattern: '^1', default: '1'} }
      validate_valid_parameter(nil)
    end
  end
end