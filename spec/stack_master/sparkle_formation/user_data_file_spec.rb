RSpec.describe SparkleFormation::SparkleAttribute::Aws, '#user_data_file!' do
  let(:user_data) do
    <<-EOS
#!/bin/bash

REGION=<%= region! %>
echo $REGION
    EOS
  end
  let(:expected_hash) do
    {"Fn::Base64"=>{"Fn::Join"=>["", ["#!/bin/bash\n\nREGION=", {"Ref"=>"AWS::Region"}, "\n", "echo $REGION\n"]]}}
  end

  before do
    klass = Class.new(AttributeStruct)
    klass.include(SparkleFormation::SparkleAttribute)
    klass.include(SparkleFormation::SparkleAttribute::Aws)
    klass.include(SparkleFormation::Utils::TypeCheckers)
    @attr = klass.new
    @attr._camel_keys = true
    @sfn = SparkleFormation.new(:test, :provider => :aws, :sparkle_path => 'spec/fixtures/test')
  end

  it 'compiles the file and returns a joined version' do
    allow(SparkleFormation).to receive(:sparkle_path).and_return('a')
    allow(File).to receive(:read).and_return(user_data)
    expect(@attr.user_data_file!('test.erb')).to eq expected_hash
  end
end
