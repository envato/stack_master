RSpec.describe StackMaster::SparkleFormation::CompileTime::MinLengthValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, definition) { "#{name}:#{error} must be at least min_length:#{definition[:min_length]} characters" } }

    context 'string validation' do
      let(:definition) { {type: :string, min_length: 2} }
      validate_valid_parameter('ab')
      validate_valid_parameter(['ab'])
      validate_invalid_parameter('a', ['a'])
      validate_invalid_parameter(['a'], ['a'])
    end

    context 'string validation with default value' do
      let(:definition) { {type: :string, min_length: 2, default: 'ab'} }
      validate_valid_parameter(nil)
    end

    context 'string validation with multiples' do
      let(:definition) { {type: :string, min_length: 2, multiple: true} }
      validate_valid_parameter('ab,cd')
      validate_invalid_parameter('a,, cd', ['a', ''])
    end

    context 'string validation with multiples and default' do
      let(:definition) { {type: :string, min_length: 2, multiple: true, default: 'ab,cd'} }
      validate_valid_parameter(nil)
    end

    context 'numerical validation' do
      let(:definition) { {type: :number, min_length: 2} }
      validate_valid_parameter('a')
    end
  end
end
