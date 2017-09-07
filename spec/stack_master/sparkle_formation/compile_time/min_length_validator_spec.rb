require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/min_length_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::MinLengthValidator do

  describe '#validate' do
    let(:name) {'name'}

    scenarios = [
        {definition: {type: :string, min_length: 2}, parameter: 'abc', valid: true},
        {definition: {type: :string, min_length: 2}, parameter: 'a', valid: false, error: ['a']},
        {definition: {type: :string, min_length: 2, default: 'abc'}, parameter: nil, valid: true},
        {definition: {type: :string, min_length: 2, default: ['abc', 'xyz']}, parameter: nil, valid: true},
        {definition: {type: :string, min_length: 2, default: ['a', 'xyz']}, parameter: nil, valid: false, error: ['a']},
        {definition: {type: :string, min_length: 2, multiple:true, default: 'abc,xyz'}, parameter: nil, valid: true},
        {definition: {type: :string, min_length: 2, multiple:true, default: 'a,xyz'}, parameter: nil, valid: false, error: ['a']},
        {definition: {type: :string, min_length: 2, multiple:true, default: 'abc,,xyz'}, parameter: nil, valid: false, error: ['']},
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
            expect(subject.error).to eql "name:#{error} must be at least min_length:#{definition[:min_length]} characters"
          end
        end
      end
    end
  end
end

