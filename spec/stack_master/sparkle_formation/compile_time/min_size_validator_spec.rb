require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/min_size_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::MinSizeValidator do

  describe '#validate' do
    let(:name) {'name'}

    scenarios = [
        {definition: {type: :number, min_size: 1}, parameter: 1, valid: true},
        {definition: {type: :number, min_size: 1}, parameter: '1', valid: true},
        {definition: {type: :number, min_size: 1}, parameter: [1], valid: true},
        {definition: {type: :number, min_size: 1}, parameter: ['1'], valid: true},
        {definition: {type: :number, min_size: 1}, parameter: 0, valid: false, error: [0]},
        {definition: {type: :number, min_size: 1}, parameter: '0', valid: false, error: ['0']},

        {definition: {type: :number, min_size: 1, default: 1}, parameter: nil, valid: true},

        {definition: {type: :string, min_size: 1}, parameter: 0, valid: true},
    
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
            expect(subject.error).to eql "name:#{error} must not be lesser than min_size:#{definition[:min_size]}"
          end
        end
      end
    end
  end
end