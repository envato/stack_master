require 'stack_master/sparkle_formation/template_file'

RSpec.describe SparkleFormation::SparkleAttribute::Aws, '#user_data_file!' do
  let(:user_data) do
    <<~EOS
      #!/bin/bash

      REGION=<%= region! %>
      echo $REGION
      <%= ref!(:test) %> <%= ref!(:test_2) %>
      <%= has_var?(:test) ? "echo 'yes'" : "echo 'no'" %>
    EOS
  end
  let(:expected_hash) do
    { 'Fn::Base64' => { 'Fn::Join' => ['', ["#!/bin/bash\n", "\n", 'REGION=', { 'Ref' => 'AWS::Region' }, "\n", "echo $REGION\n", { 'Ref' => 'Test' }, ' ', { 'Ref' => 'Test2' }, "\n", "echo 'no'", "\n"]] } }
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
        <<~EOS
          #!/bin/bash
          <%= my_custom_var %>
          <%= has_var?(:my_custom_var) ? "yes" : "no" %>
        EOS
      end
      let(:expected_hash) do
        { 'Fn::Base64' => { 'Fn::Join' => ['', ["#!/bin/bash\n", 'test_var', "\n", 'yes', "\n"]] } }
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
      expect do
        @attr.user_data_file!('test.erb')
      end.to raise_error(StackMaster::SparkleFormation::TemplateFileNotFound)
    end
  end

  context 'with nested templates' do
    let(:inner_user_data) do
      <<~EOS
        REGION=<%= region! %>
        <%= test1 %>
        <%= has_var?(:test2) ? 'yes' : 'no' %>
      EOS
    end

    let(:outer_user_data) do
      <<~EOS
        #!/bin/bash
        <%= test1 %> <%= test2 %>
        <%= render 'inner.sh.erb', test1: 'inner1' %>
      EOS
    end

    let(:expected_hash) do
      { 'Fn::Base64' => { 'Fn::Join' => ['', ["#!/bin/bash\n", 'outer1', ' ', 'outer2', "\n", 'REGION=', { 'Ref' => 'AWS::Region' }, "\n", 'inner1', "\n", 'no', "\n", "\n"]] } }
    end

    before do
      allow(File).to receive(:read).and_call_original
      allow(File).to receive(:read).with('/templates_dir/user_data/outer.sh.erb').and_return(outer_user_data)
      allow(File).to receive(:read).with('/templates_dir/user_data/inner.sh.erb').and_return(inner_user_data)
    end

    it 'renders the outer template, including the inner template with its own var context' do
      expect(@attr.user_data_file!('outer.sh.erb', test1: :outer1, test2: 'outer2')).to eq expected_hash
    end
  end
end

RSpec.describe SparkleFormation::SparkleAttribute::Aws, '#joined_file!' do
  let(:config) do
    <<~EOS
      variable=<%= ref!(:test) %>
    EOS
  end

  let(:expected_hash) do
    { 'Fn::Join' => ['', ['variable=', { 'Ref' => 'Test' }, "\n"]] }
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
