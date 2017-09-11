require 'spec_helper'

RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedPatternValidator do

  describe '#validate' do
    context 'string validation' do
      let(:validator_definition) { {type: :string, allowed_pattern: '^a'} }

      include_examples 'validate valid parameter', described_class, 'a'
      include_examples 'validate valid parameter', described_class, ['a']
      include_examples 'validate invalid parameter', described_class, 'b', ['b']
    end

    context 'numerical validation' do
      let(:validator_definition) { {type: :number, allowed_pattern: '^1'} }

      include_examples 'validate valid parameter', described_class, 1
      include_examples 'validate valid parameter', described_class, '1'
      include_examples 'validate valid parameter', described_class, [1]
      include_examples 'validate valid parameter', described_class, ['1']

      include_examples 'validate invalid parameter', described_class, 2, ['2']
      include_examples 'validate invalid parameter', described_class, '2', ['2']
      include_examples 'validate invalid parameter', described_class, '2', ['2']
    end

    context 'validation with default value' do
      let(:validator_definition) { {type: :number, allowed_pattern: '^1', default: '1'} }
      include_examples 'validate valid parameter', described_class, nil
    end
  end
end