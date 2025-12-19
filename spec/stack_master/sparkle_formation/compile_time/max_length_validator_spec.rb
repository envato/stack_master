RSpec.describe StackMaster::SparkleFormation::CompileTime::MaxLengthValidator do
  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) do
      lambda { |error, definition|
        "#{name}:#{error} must not exceed max_length:#{definition[:max_length]} characters"
      }
    end

    context 'string validation' do
      let(:definition) { { type: :string, max_length: 1 } }
      validate_valid_parameter('a')
      validate_valid_parameter(['a'])
      validate_invalid_parameter('ab', ['ab'])
      validate_invalid_parameter(['ab'], ['ab'])
    end

    context 'string validation with default value' do
      let(:definition) { { type: :string, max_length: 1, default: 'a' } }
      validate_valid_parameter(nil)
    end

    context 'string validation with multiples' do
      let(:definition) { { type: :string, max_length: 1, multiple: true } }
      validate_valid_parameter('a,a')
      validate_valid_parameter('a,,a')
      validate_invalid_parameter('a,, ab', ['ab'])
    end

    context 'string validation wtih multiples and default' do
      let(:definition) { { type: :string, max_length: 1, multiple: true, default: 'a,a' } }
      validate_valid_parameter(nil)
    end

    context 'numerical validation' do
      let(:definition) { { type: :number, max_length: 1 } }
      validate_valid_parameter('ab')
    end
  end
end
