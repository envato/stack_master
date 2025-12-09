RSpec.describe StackMaster::SparkleFormation::CompileTime::StringValidator do
  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { ->(error, _definition) { "#{name}:#{error} are not Strings" } }

    context 'string validation' do
      let(:definition) { { type: :string } }
      validate_valid_parameter('a')
      validate_valid_parameter([''])
      validate_invalid_parameter({}, [{}])
    end

    context 'string validation default' do
      let(:definition) { { type: :string, default: 'a' } }
      validate_valid_parameter(nil)
    end

    context 'string validation with multiples' do
      let(:definition) { { type: :string, multiple: true } }
      validate_valid_parameter('a,b')
      validate_invalid_parameter([{}], [{}])
    end

    context 'string validation with multiples and default' do
      let(:definition) { { type: :string, multiple: true, default: 'a,a' } }
      validate_valid_parameter(nil)
    end

    context 'numerical validation' do
      let(:definition) { { type: :number } }
      validate_valid_parameter(1)
    end
  end
end
