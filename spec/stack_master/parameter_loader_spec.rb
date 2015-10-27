RSpec.describe StackMaster::ParameterLoader do
  subject(:parameters) { StackMaster::ParameterLoader.load(parameter_files) }
  let(:parameter_files) { [
    '/base_dir/parameters/stack_name.yml',
    '/base_dir/parameters/us-east-1/stack_name.yml'
  ] }

  context "no parameter file" do
    before do
      allow(File).to receive(:exists?).and_return(false)
    end

    it "returns empty parameters" do
      expect(parameters).to eq({})
    end
  end

  context "an empty stack parameter file" do
    before do
      allow(File).to receive(:exists?).with('/base_dir/parameters/stack_name.yml').and_return(true)
      allow(File).to receive(:exists?).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return(false)
      allow(File).to receive(:read).with('/base_dir/parameters/stack_name.yml').and_return("")
    end

    it "returns an empty hash" do
      expect(parameters).to eq({})
    end
  end

  context "stack parameter file" do
    before do
      allow(File).to receive(:exists?).with('/base_dir/parameters/stack_name.yml').and_return(true)
      allow(File).to receive(:exists?).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return(false)
      allow(File).to receive(:read).with('/base_dir/parameters/stack_name.yml').and_return("param1: value1")
    end

    it "returns params from stack_name.yml" do
      expect(parameters).to eq({ 'param1' => 'value1' })
    end
  end

  context "region parameter file" do
    before do
      allow(File).to receive(:exists?).with('/base_dir/parameters/stack_name.yml').and_return(false)
      allow(File).to receive(:exists?).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return(true)
      allow(File).to receive(:read).with('/base_dir/parameters/us-east-1/stack_name.yml').and_return("param2: value2")
    end

    it "returns params from the region base stack_name.yml" do
      expect(parameters).to eq({ 'param2' => 'value2' })
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
      expect(parameters).to eq({
                                                  'param1' => 'value1',
                                                  'param2' => 'value2'
                                                })
    end
  end
end
