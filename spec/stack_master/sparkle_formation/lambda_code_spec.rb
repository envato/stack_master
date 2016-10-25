require 'stack_master/sparkle_formation/lambda_code'

RSpec.describe SparkleFormation::SparkleAttribute::Aws, '#lambda_code!' do
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
    allow(File).to receive(:file?).and_return(true)
    expect(File).to receive(:read).with('/templates_dir/lambda_functions/test.erb').and_return(lambda_function_code)
    @attr.lambda_code!('test.erb')
  end

  context 'when the location exists and is a file' do
    before do
      allow(File).to receive(:file?).and_return(true)
      allow(File).to receive(:read).and_return(lambda_function_code)
    end

    it 'compiles the file and returns a joined version' do
      expect(@attr.lambda_code!('test.erb')).to eq expected_hash
    end
  end

  context 'when the location exists and is a directory' do
    before do
      allow(File).to receive(:directory?).and_return(true)
      allow(StackMaster.s3_driver).to receive(:upload_files).and_return(true)
    end

    it 'zips the directory, uploads to s3 and returns an S3 path' do
      expect(@attr.lambda_code!('test_dir')).to eq 'https://s3.amazonaws.com/envato-hack-fort-lambda-functions/stack_master/test_dir.zip'
    end
  end

  context "when the location doesn't exist" do
    before do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
    end

    it 'raises a specific error' do
      expect {
        @attr.lambda_code!('test.erb')
      }.to raise_error(StackMaster::SparkleFormation::LambdaCodeFileNotFound)
    end
  end
end
