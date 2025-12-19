RSpec.describe StackMaster::SparkleFormation::CompileTime::NumberValidator do
  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { ->(error, _definition) { "#{name}:#{error} are not Numbers" } }

    context 'numerical validation' do
      let(:definition) { { type: :number } }
      validate_valid_parameter(1)
      validate_valid_parameter(['1'])
      validate_invalid_parameter(['1.'], ['1.'])
      validate_invalid_parameter(['.1'], ['.1'])
      validate_invalid_parameter(['1.1.1'], ['1.1.1'])
      validate_invalid_parameter(['1a1'], ['1a1'])
    end

    context 'numerical validation with default' do
      let(:definition) { { type: :number, default: 1 } }
      validate_valid_parameter(nil)
    end

    context 'numerical validation with multiples' do
      let(:definition) { { type: :number, multiple: true } }
      validate_valid_parameter('1,2')
      validate_valid_parameter([1, 2])
      validate_invalid_parameter('1,1.', ['1.'])
      validate_invalid_parameter({}, [{}])
    end

    context 'numerical validation with multiples and default' do
      let(:definition) { { type: :number, multiple: true, default: '1,2' } }
      validate_valid_parameter(nil)
    end

    context 'string validation' do
      let(:definition) { { type: :string } }
      validate_valid_parameter('a')
    end
  end
end
