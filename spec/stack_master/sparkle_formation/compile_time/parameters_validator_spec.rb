require_relative '../../../../lib/stack_master/sparkle_formation/compile_time/parameters_validator'

RSpec.describe StackMaster::SparkleFormation::CompileTime::ParametersValidator do

  describe '#validate' do

    let(:name) {'name'}
    let(:definitions) {}

    subject {described_class.new(definitions, parameters).validate}

  end

end