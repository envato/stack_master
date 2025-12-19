RSpec.describe StackMaster::SparkleFormation::CompileTime::MinSizeValidator do
  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) do
      lambda { |error, definition|
        "#{name}:#{error} must not be lesser than min_size:#{definition[:min_size]}"
      }
    end

    context 'numerical validation' do
      let(:definition) { { type: :number, min_size: 1 } }
      validate_valid_parameter(1)
      validate_valid_parameter('1')
      validate_valid_parameter([1])
      validate_valid_parameter(['1'])
      validate_invalid_parameter(0, [0])
      validate_invalid_parameter('0', ['0'])
    end

    context 'numerical validation with default value' do
      let(:definition) { { type: :number, min_size: 1, default: 1 } }
      validate_valid_parameter(nil)
    end

    context 'string validation' do
      let(:definition) { { type: :string, min_size: 1 } }
      validate_valid_parameter(0)
    end
  end
end
