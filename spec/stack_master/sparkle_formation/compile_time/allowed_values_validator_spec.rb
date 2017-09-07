require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/allowed_values_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedValuesValidator do

  describe '#validate' do

    let(:name) {'name'}

    scenarios = [
        {definition: {type: :string, allowed_values: ['a']}, parameter: 'a', valid: true},
        {definition: {type: :string, allowed_values: ['a']}, parameter: ['a'], valid: true},
        {definition: {type: :string, allowed_values: ['a']}, parameter: 'b', valid: false, error: ['b']},
        {definition: {type: :string, allowed_values: ['a']}, parameter: ['b'], valid: false, error: ['b']},

        {definition: {type: :string, allowed_values: ['a'], default: 'a'}, parameter: nil, valid: true},

        {definition: {type: :string, allowed_values: ['a'], multiple: true}, parameter: 'a,a', valid: true},
        {definition: {type: :string, allowed_values: ['a'], multiple: true}, parameter: 'a,, a', valid: false, error: ['']},
        {definition: {type: :string, allowed_values: ['a'], multiple: true}, parameter: 'a,,b', valid: false, error: ['', 'b']},

        {definition: {type: :string, allowed_values: ['a'], multiple: true, default: 'a,a'}, parameter: nil, valid: true},

        {definition: {type: :number, allowed_values: [1]}, parameter: '1', valid: true},
        {definition: {type: :number, allowed_values: [1]}, parameter: 1, valid: true},
        {definition: {type: :number, allowed_values: [1]}, parameter: [1], valid: true},
        {definition: {type: :number, allowed_values: [1]}, parameter: ['1'], valid: true},
        {definition: {type: :number, allowed_values: [1]}, parameter: '2', valid: false, error: ['2']},
        {definition: {type: :number, allowed_values: [1]}, parameter: 2, valid: false, error: [2]},

        {definition: {type: :number, allowed_values: [1], default: 1}, parameter: nil, valid: true},
    ]

    subject {described_class.new(name, definition, parameter).tap {|validator| validator.validate}}

    scenarios.each do |scenario|
      context_description = scenario.clone.tap {|clone| clone.delete(:valid); clone.delete(:error)}
      context "when #{context_description}" do
        let(:definition) {scenario[:definition]}
        let(:parameter) {scenario[:parameter]}
        let(:error) {scenario[:error]}
        if scenario[:valid]
          it 'should be valid' do
            expect(subject.is_valid).to be_truthy
          end
        else
          it 'should not be valid' do
            expect(subject.is_valid).to be_falsey
          end
          it 'should have an error' do
            expect(subject.error).to eql "name:#{error} is not in allowed_values:#{definition[:allowed_values]}"
          end
        end
      end
    end
  end
end