require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/value_validator_factory'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/empty_validator'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/string_validator'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/number_validator'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/allowed_values_validator'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/allowed_pattern_validator'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/max_length_validator'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/min_length_validator'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/max_size_validator'
require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/min_size_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::ValueValidatorFactory do

  let(:name) {:ip}
  let(:definition) {{type: :string}}
  let(:parameter) {{'Ip' => '10.0.0.0'}}

  subject {described_class.new(name, definition, parameter)}

  describe '#build' do

    validators = [
        StackMaster::SparkleFormation::CompileTime::EmptyValidator,
        StackMaster::SparkleFormation::CompileTime::StringValidator,
        StackMaster::SparkleFormation::CompileTime::NumberValidator,
        StackMaster::SparkleFormation::CompileTime::AllowedValuesValidator,
        StackMaster::SparkleFormation::CompileTime::AllowedPatternValidator,
        StackMaster::SparkleFormation::CompileTime::MaxLengthValidator,
        StackMaster::SparkleFormation::CompileTime::MinLengthValidator,
        StackMaster::SparkleFormation::CompileTime::MaxSizeValidator,
        StackMaster::SparkleFormation::CompileTime::MinSizeValidator]

    after(:each){subject.build}

    validators.each do |validator|

      it "should build a #{validator} with correct parameters" do
        expect(validator).to receive(:new).with(name, definition, parameter)
      end

    end

    it 'should build in the correct order' do
      validators.each do |validator|
        expect(validator).to receive(:new).ordered
      end
    end

  end

end