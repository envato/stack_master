RSpec.describe StackMaster::SparkleFormation::CompileTime::MaxSizeValidator do
  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) do
      lambda { |error, definition|
        "#{name}:#{error} must not be greater than max_size:#{definition[:max_size]}"
      }
    end

    context 'numerical validation' do
      let(:definition) { { type: :number, max_size: 1 } }
      validate_valid_parameter(1)
      validate_valid_parameter('1')
      validate_valid_parameter([1])
      validate_valid_parameter(['1'])
      validate_invalid_parameter(2, [2])
      validate_invalid_parameter('2', ['2'])
    end

    context 'numerical validation with default' do
      let(:definition) { { type: :number, max_size: 1, default: 1 } }
      validate_valid_parameter(nil)
    end

    context 'string validation' do
      let(:definition) { { type: :string, max_size: 1 } }
      validate_valid_parameter(2)
    end
  end
end
