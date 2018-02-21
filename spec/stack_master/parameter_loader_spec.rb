RSpec.describe StackMaster::ParameterLoader do
  let(:stack_file_name) { '/base_dir/parameters/stack_name.yml' }
  let(:region_file_name) { '/base_dir/parameters/us-east-1/stack_name.yml' }

  subject(:parameters) { StackMaster::ParameterLoader.load([stack_file_name, region_file_name]) }

  before do
    file_mock(stack_file_name, stack_file_returns)
    file_mock(region_file_name, region_file_returns)
  end

  context 'no parameter file' do
    let(:stack_file_returns) { {exists: false} }
    let(:region_file_returns) { {exists: false} }

    it 'returns empty parameters' do
      expect(parameters).to eq(template_parameters: {}, compile_time_parameters: {})
    end
  end

  context 'an empty stack parameter file' do
    let(:stack_file_returns) { {exists: true, read: ''} }
    let(:region_file_returns) { {exists: false} }

    it 'returns an empty hash' do
      expect(parameters).to eq({template_parameters: {}, compile_time_parameters: {}})
    end
  end

  context 'stack parameter file' do
    let(:stack_file_returns) { {exists: true, read: 'Param1: value1'} }
    let(:region_file_returns) { {exists: false} }

    it 'returns params from stack_name.yml' do
      expect(parameters).to eq(template_parameters: {'Param1' => 'value1'}, compile_time_parameters: {})
    end
  end

  context 'region parameter file' do
    let(:stack_file_returns) { {exists: false } }
    let(:region_file_returns) { {exists: true, read: 'Param2: value2'} }

    it 'returns params from the region base stack_name.yml' do
      expect(parameters).to eq(template_parameters: {'Param2' => 'value2'}, compile_time_parameters: {})
    end
  end

  context 'stack and region parameter file' do
    let(:stack_file_returns) { {exists: true, read: "Param1: value1\nParam2: valueX" } }
    let(:region_file_returns) { {exists: true, read: 'Param2: value2'} }

    it 'returns params from the region base stack_name.yml' do
      expect(parameters).to eq(template_parameters: {'Param1' => 'value1', 'Param2' => 'value2'}, compile_time_parameters: {})
    end
  end

  context 'yml and yaml region parameter files' do
    let(:stack_file_returns) { {exists: false} }
    let(:region_file_returns) { {exists: true, read: "Param2: value2"} }
    let(:region_yaml_file_returns) { {exists: true, read: "Param1: value1\nParam2: valueX"} }
    let(:region_yaml_file_name) { "/base_dir/parameters/us-east-1/stack_name.yaml" }

    subject(:parameters) { StackMaster::ParameterLoader.load([stack_file_name, region_yaml_file_name, region_file_name]) }

    before do
      file_mock(region_yaml_file_name, region_yaml_file_returns)
    end

    it 'returns params from the region base stack_name.yml' do
      expect(parameters).to eq(template_parameters: {'Param1' => 'value1', 'Param2' => 'value2'}, compile_time_parameters: {})
    end
  end

  context 'compile time parameters' do

    context 'stack parameter file' do
      let(:stack_file_returns) { {exists: true, read: "Param1: value1\nCompileTimeParameters:\n  Param2: value2" } }
      let(:region_file_returns) { {exists: false} }

      it 'returns params from stack_name.yml' do
        expect(parameters).to eq(template_parameters: {'Param1' => 'value1'}, compile_time_parameters: {'Param2' => 'value2'})
      end
    end

    context 'stack and region parameter file' do
      let(:stack_file_returns) { {exists: true, read: "Param1: value1\nCompileTimeParameters:\n  Param2: valueX" } }
      let(:region_file_returns) { {exists: true, read: "CompileTimeParameters:\n  Param2: value2"} }

      it 'returns params from the region base stack_name.yml' do
        expect(parameters).to eq(template_parameters: {'Param1' => 'value1'}, compile_time_parameters: {'Param2' => 'value2'})
      end
    end

  end

  context 'underscored parameter names' do
    let(:stack_file_returns) { {exists: true, read: 'vpc_id: vpc-xxxxxx' } }
    let(:region_file_returns) { {exists: false} }

    it 'camelcases them' do
      expect(parameters).to eq(template_parameters: {'VpcId' => 'vpc-xxxxxx'}, compile_time_parameters: {})
    end
  end

  def file_mock(file_name, exists: false, read: nil)
    allow(File).to receive(:exists?).with(file_name).and_return(exists)
    allow(File).to receive(:read).with(file_name).and_return(read) if read
  end

end
