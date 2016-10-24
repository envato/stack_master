require 'stack_master/sparkle_formation/lambda_function'

RSpec.describe SparkleFormation::SparkleAttribute::Aws, '#lambda_function!' do
  let(:lambda_function_code) do
    <<-EOS
'use strict';
console.log('Loading function');

exports.handler = (event, context, callback) => {
 console.log('Received event', JSON.stringify(event, null, 2));
 callback(null, event.key1);  // Echo back the first key value
};
    EOS
  end
  let(:expected_hash) do
    "\'use strict\';\nconsole.log('Loading function');\n\nexports.handler = (event, context, callback) => {\n console.log('Received event', JSON.stringify(event, null, 2));\n callback(null, event.key1);  // Echo back the first key value\n};\n"
  end

  before do
    allow(SparkleFormation).to receive(:sparkle_path).and_return('/templates_dir')
    klass = Class.new(AttributeStruct)
    klass.include(SparkleFormation::SparkleAttribute)
    klass.include(SparkleFormation::SparkleAttribute::Aws)
    klass.include(SparkleFormation::Utils::TypeCheckers)
    @attr = klass.new
    @attr._camel_keys = true
  end

  it 'reads from the lambda_functions dir in templates' do
    expect(File).to receive(:read).with('/templates_dir/lambda_functions/test.erb').and_return(lambda_function_code)
    @attr.lambda_function!('test.erb')
  end

  context 'when the file exists' do
    before do
      allow(File).to receive(:read).and_return(lambda_function_code)
    end

    it 'compiles the file and returns a joined version' do
      expect(@attr.lambda_function!('test.erb')).to eq expected_hash
    end

  end

  context "when the file doesn't exist" do
    before do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
    end

    it 'raises a specific error' do
      expect {
        @attr.lambda_function!('test.erb')
      }.to raise_error(StackMaster::SparkleFormation::LambdaFunctionFileNotFound)
    end
  end
end
