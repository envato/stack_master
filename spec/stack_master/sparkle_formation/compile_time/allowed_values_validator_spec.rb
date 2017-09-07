require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/allowed_values_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::AllowedValuesValidator do

  describe '#validate' do

    let(:name) {'name'}

    scenarios = [
        {definition: {type: :string, allowed_values: %w(a b)}, parameter: 'a', valid: true},
        {definition: {type: :string, allowed_values: %w(a b)}, parameter: 'a,b', valid: false, error: '["a,b"]'},
        {definition: {type: :string, allowed_values: %w(c)}, parameter: 'a,b', valid: false, error: '["a,b"]'},
        {definition: {type: :string, allowed_values: %w(c)}, parameter: 'a', valid: false, error: '["a"]'},
        {definition: {type: :string, allowed_values: %w(c)}, parameter: %w(a b), valid: false, error: '["a", "b"]'},
        {definition: {type: :string, multiple: true, allowed_values: %w(a b)}, parameter: 'a,b', valid: true},
        {definition: {type: :string, multiple: true, allowed_values: %w(a b)}, parameter: 'a, b', valid: true},
        {definition: {type: :string, multiple: true, allowed_values: ['c']}, parameter: 'a', valid: false, error: '["a"]'},
        {definition: {type: :string, multiple: true, allowed_values: ['c']}, parameter: 'a,b', valid: false, error: '["a", "b"]'},
        {definition: {type: :string, multiple: true, allowed_values: ['c']}, parameter: 'a, b', valid: false, error: '["a", "b"]'},
        {definition: {type: :string, multiple: true, allowed_values: ['c'], default: 'c'}, parameter: nil, valid: true},
        {definition: {type: :number, allowed_values: %w(1 2)}, parameter: '1', valid: true},
        {definition: {type: :number, allowed_values: %w(1 2)}, parameter: %w(1 2), valid: true},
        {definition: {type: :number, allowed_values: %w(1 2)}, parameter: ['1','2'], valid: true},
        {definition: {type: :number, allowed_values: %w(3)}, parameter: %w(1 2), valid: false, error: '["1", "2"]'},
        {definition: {type: :number, allowed_values: %w(3)}, parameter: ['1','2'], valid: false, error: '["1", "2"]'},
        {definition: {type: :number, allowed_values: %w(1), default: '1'}, parameter: nil, valid: true}
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