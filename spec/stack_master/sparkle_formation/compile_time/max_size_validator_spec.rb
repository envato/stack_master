require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/max_size_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::MaxSizeValidator do

  describe '#validate' do
    let(:name) {'name'}

    scenarios = [
        {definition: {type: :number, max_size: 2}, parameter: 2, valid: true},
        {definition: {type: :number, max_size: 2}, parameter: '2', valid: true},
        {definition: {type: :number, max_size: 2}, parameter: 3, valid: false, error: [3]},
        {definition: {type: :number, max_size: 2, default: 2}, parameter: nil, valid: true},
        {definition: {type: :number, max_size: 2, default: 3}, parameter: nil, valid: false, error: [3]}
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
            expect(subject.error).to eql "name:#{error} must not be greater than max_size:#{definition[:max_size]}"
          end
        end
      end
    end
  end
end