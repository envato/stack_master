require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/string_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::StringValidator do

  describe '#validate' do
    let(:name) { 'name' }
    let(:error_message) { -> (error, _definition) { "#{name}:#{error} are not Strings" } }

    context 'string validation' do
      let(:definition) { {type: :string} }
      include_examples 'validate valid parameter', 'a'
      include_examples 'validate valid parameter', ['a']
      include_examples 'validate invalid parameter', {}, [{}]
    end

    context 'string validation default' do
      let(:definition) { {type: :string, default: 'a'} }
      include_examples 'validate valid parameter', nil
    end

    context 'string validation with multiples' do
      let(:definition) { {type: :string, multiple: true} }
      include_examples 'validate valid parameter', 'a,b'
      include_examples 'validate invalid parameter', [{}], [{}]
    end

    context 'string validation with multiples and default' do
      let(:definition) { {type: :string, multiple: true, default: 'a,a'} }
      include_examples 'validate valid parameter', nil
    end

    context 'numerical validation' do
      let(:definition) { {type: :number} }
      include_examples 'validate valid parameter', 1
    end
  end
end
