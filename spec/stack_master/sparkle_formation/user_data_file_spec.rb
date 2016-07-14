RSpec.describe SparkleFormation::SparkleAttribute::Aws, '#user_data_file!' do
  let(:user_data) do
    <<-EOS
#!/bin/bash

REGION=<%= region! %>
echo $REGION
    EOS
  end
  let(:expected_hash) do
    {"Fn::Base64"=>{"Fn::Join"=>["", ["#!/bin/bash\n", "\n", "REGION=", {"Ref"=>"AWS::Region"}, "echo $REGION\n"]]}}
  end

  before do
    allow(SparkleFormation).to receive(:sparkle_path).and_return('/templates_dir')
    klass = Class.new(AttributeStruct)
    klass.include(SparkleFormation::SparkleAttribute)
    klass.include(SparkleFormation::SparkleAttribute::Aws)
    klass.include(SparkleFormation::Utils::TypeCheckers)
    @attr = klass.new
    @attr._camel_keys = true
    @sfn = SparkleFormation.new(:test, :provider => :aws, :sparkle_path => 'spec/fixtures/test')
  end

  it 'reads from the user_data dir in templates' do
    expect(File).to receive(:read).with('/templates_dir/user_data/test.erb').and_return(user_data)
    @attr.user_data_file!('test.erb')
  end

  context 'when the file exists' do
    before do
      allow(File).to receive(:read).and_return(user_data)
    end

    it 'compiles the file and returns a joined version' do
      expect(@attr.user_data_file!('test.erb')).to eq expected_hash
    end
  end

  context "when the file doesn't exist" do
    before do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
    end

    it 'raises a specific error' do
      expect {
        @attr.user_data_file!('test.erb')
      }.to raise_error(SparkleFormation::SparkleAttribute::Aws::UserDataFileNotFound)
    end
  end
end
