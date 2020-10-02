RSpec.describe StackMaster::SparkleFormation::CompileTime::EmptyValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, _definition) { "#{name} cannot contain empty parameters:#{error.inspect}" } }

    context 'string validation' do
      let(:definition) { {type: :string} }
      validate_valid_parameter('a')
      validate_valid_parameter(['a'])
      validate_invalid_parameter(nil, nil)
      validate_invalid_parameter(['a', nil], ['a', nil])
    end

    context 'string validation with default' do
      let(:definition) { {type: :string, default: 'a'} }
      validate_valid_parameter(nil)
    end

    context 'string validation with multiples' do
      let(:definition) { {type: :string, multiple: true} }
      validate_valid_parameter('a,b')
      validate_valid_parameter('a,,b')
    end

    context 'string validation with multiples and defaults' do
      let(:definition) { {type: :string, multiple: true, default: 'a,b'} }
      validate_valid_parameter(nil)
    end

    context 'numerical validation' do
      let(:definition) { {type: :number} }
      validate_valid_parameter(1)
      validate_valid_parameter('1')
      validate_valid_parameter([1])
      validate_valid_parameter(['1'])
      validate_invalid_parameter(nil, nil)
      validate_invalid_parameter([1, nil], [1, nil])
      validate_invalid_parameter(['1', nil], ['1', nil])
    end

    context 'numerical validation with default' do
      let(:definition) { {type: :number, default: '1'} }
      validate_valid_parameter(nil)
    end
  end
end
