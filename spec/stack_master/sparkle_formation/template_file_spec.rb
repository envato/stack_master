require 'stack_master/sparkle_formation/template_file'

RSpec.describe SparkleFormation::SparkleAttribute::Aws, '#user_data_file!' do
  let(:user_data) do
    <<-EOS
#!/bin/bash

REGION=<%= region! %>
echo $REGION
<%= ref!(:test) %> <%= ref!(:test_2) %>
<%= has_var?(:test) ? "echo 'yes'" : "echo 'no'" %>
    EOS
  end
  let(:expected_hash) do
    {"Fn::Base64"=>{"Fn::Join"=>["", ["#!/bin/bash\n", "\n", "REGION=", {"Ref"=>"AWS::Region"}, "\n", "echo $REGION\n", {"Ref"=>"Test"}, " ", {"Ref"=>"Test2"}, "\n", "echo 'no'", "\n"]]}}
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

    context 'with custom vars' do
      let(:user_data) do
        <<-EOS
#!/bin/bash
<%= my_custom_var %>
<%= has_var?(:my_custom_var) ? "yes" : "no" %>
        EOS
      end
      let(:expected_hash) do
        {"Fn::Base64"=>{"Fn::Join"=>["", ["#!/bin/bash\n", "test_var", "\n", "yes", "\n"]]}}
      end

      it 'compiles the file and returns a joined version' do
        expect(@attr.user_data_file!('test.erb', my_custom_var: :test_var)).to eq expected_hash
        expect(@attr.user_data_file!('test.erb', my_custom_var: 'test_var')).to eq expected_hash
      end
    end
  end

  context "when the file doesn't exist" do
    before do
      allow(File).to receive(:read).and_raise(Errno::ENOENT)
    end

    it 'raises a specific error' do
      expect {
        @attr.user_data_file!('test.erb')
      }.to raise_error(StackMaster::SparkleFormation::TemplateFileNotFound)
    end
  end
end

RSpec.describe SparkleFormation::SparkleAttribute::Aws, '#joined_file!' do
  let(:config) do
    <<-EOS
variable=<%= ref!(:test) %>
    EOS
  end

  let(:expected_hash) do
    {"Fn::Join"=>["", ["variable=", {"Ref"=>"Test"}, "\n"]]}
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

  it 'reads from the config dir in templates' do
    expect(File).to receive(:read).with('/templates_dir/joined_file/test.erb').and_return(config)
    @attr.joined_file!('test.erb')
  end

  context 'when the file exists' do
    before do
      allow(File).to receive(:read).and_return(config)
    end

    it 'compiles the file and returns a joined version' do
      expect(@attr.joined_file!('test.erb')).to eq expected_hash
    end
  end
end
