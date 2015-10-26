RSpec.describe StackMaster::Config::StackDefinition do

  subject(:stack_definition) do
    StackMaster::Config::StackDefinition.new(
      region: region,
      stack_name: stack_name,
      template: template,
      tags: tags,
      base_dir: base_dir)
  end

  let(:region) { 'us-east-1' }
  let(:stack_name) { 'stack_name' }
  let(:template) { 'template.json' }
  let(:tags) { {'environment' => 'production'} }
  let(:base_dir) { '/base_dir' }

  describe "#aws_tags" do
    it "converts the tags attribute to aws format" do
      expect(stack_definition.aws_tags).to eq( [{key: 'environment', value: 'production'} ])
    end

    context "tags is nil" do
      let(:tags) { nil }

      it "returns nil" do
        expect(stack_definition.aws_tags).to eq([])
      end
    end
  end

  describe "#parameters" do
    context "no parameter file" do
      before do
        allow(File).to receive(:exists?).and_return(false)
      end

      it "returns empty parameters" do
        expect(stack_definition.parameters).to eq({})
      end
    end
    context "stack parameter file" do
      before do
        allow(File).to receive(:exists?).with('/base_dir/parameters/stack_name.yml').and_return(true)
        allow(File).to receive(:exists?).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return(false)
        allow(File).to receive(:read).with('/base_dir/parameters/stack_name.yml').and_return("param1: value1")
      end

      it "returns params from stack_name.yml" do
        expect(stack_definition.parameters).to eq({ 'param1' => 'value1' })
      end
    end
    context "region parameter file" do
      before do
        allow(File).to receive(:exists?).with('/base_dir/parameters/stack_name.yml').and_return(false)
        allow(File).to receive(:exists?).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return(true)
        allow(File).to receive(:read).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return("param2: value2")
      end

      it "returns params from the region base stack_name.yml" do
        expect(stack_definition.parameters).to eq({ 'param2' => 'value2' })
      end
    end
    context "stack and region parameter file" do
      before do
        allow(File).to receive(:exists?).with('/base_dir/parameters/stack_name.yml').and_return(true)
        allow(File).to receive(:exists?).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return(true)
        allow(File).to receive(:read).with('/base_dir/parameters/stack_name.yml').and_return("param1: value1\nparam2: valueX")
        allow(File).to receive(:read).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return("param2: value2")
      end

      it "returns params from the region base stack_name.yml" do
        expect(stack_definition.parameters).to eq({
                                                    'param1' => 'value1',
                                                    'param2' => 'value2'
                                                  })
      end
    end
  end

  describe "#aws_parameters" do
    before do
      allow(File).to receive(:exists?).and_return(true, false)
      allow(File).to receive(:read).with('/base_dir/parameters/stack_name.yml').and_return(yaml_params)
    end
    let(:yaml_params) { <<EOF }
param1: value1
param2: value2
EOF

    it "loads the parameter file and returns the parameters" do
      expect(stack_definition.aws_parameters).to eq([{parameter_key: 'param1', parameter_value: 'value1'},
                                                     {parameter_key: 'param2', parameter_value: 'value2'}])
    end
  end

  describe "#template_body" do
    it "reads from the template file path" do
      expect(File).to receive(:read).with('/base_dir/templates/template.json').and_return('body')

      expect(stack_definition.template_body).to eq('body')
    end
  end

end
