RSpec.describe StackMaster::ParameterLoader do

  let(:stack_file_name) { '/base_dir/parameters/stack_name.yml' }
  let(:region_file_name) { '/base_dir/parameters/us-east-1/stack_name.yml' }

  subject(:parameters) { StackMaster::ParameterLoader.load([stack_file_name, region_file_name]) }

  context 'no parameter file' do
    before do
      file_mock(stack_file_name, false)
      file_mock(region_file_name, false)
    end

    it 'returns empty parameters' do
      expect(parameters).to eq(template_parameters: {}, compile_time_parameters: {})
    end
  end

  context 'an empty stack parameter file' do
    before do
      file_mock(stack_file_name, true, '')
      file_mock(region_file_name, false)
    end

    it 'returns an empty hash' do
      expect(parameters).to eq({template_parameters: {}, compile_time_parameters: {}})
    end
  end

  context 'stack parameter file' do
    before do
      file_mock(stack_file_name, true, 'Param1: value1')
      file_mock(region_file_name, false)
    end

    it 'returns params from stack_name.yml' do
      expect(parameters).to eq(template_parameters: {'Param1' => 'value1'}, compile_time_parameters: {})
    end
  end

  context 'region parameter file' do
    before do
      file_mock(stack_file_name, false)
      file_mock(region_file_name, true, 'Param2: value2')
    end

    it 'returns params from the region base stack_name.yml' do
      expect(parameters).to eq(template_parameters: {'Param2' => 'value2'}, compile_time_parameters: {})
    end
  end

  context 'stack and region parameter file' do
    before do
      file_mock(stack_file_name, true, "Param1: value1\nParam2: valueX")
      file_mock(region_file_name, true, 'Param2: value2')
    end

    it 'returns params from the region base stack_name.yml' do
      expect(parameters).to eq(template_parameters: {'Param1' => 'value1', 'Param2' => 'value2'}, compile_time_parameters: {})
    end
  end

  context 'compile time parameters' do

    context 'stack parameter file' do
      before do
        file_mock(stack_file_name, true, "Param1: value1\nCompileTimeParameters:\n  Param2: value2")
        file_mock(region_file_name, false)
      end

      it 'returns params from stack_name.yml' do
        expect(parameters).to eq(template_parameters:{'Param1' => 'value1'}, compile_time_parameters:{'Param2' => 'value2'})
      end
    end

    context 'stack and region parameter file' do
      before do
        file_mock(stack_file_name, true, "Param1: value1\nCompileTimeParameters:\n  Param2: valueX")
        file_mock(region_file_name, true, "CompileTimeParameters:\n  Param2: value2")
      end

      it 'returns params from the region base stack_name.yml' do
        expect(parameters).to eq(template_parameters: {'Param1' => 'value1'}, compile_time_parameters:{'Param2' => 'value2'})
      end
    end

  end

  context 'underscored parameter names' do
    before do
      file_mock(stack_file_name, true, 'vpc_id: vpc-xxxxxx')
      file_mock(region_file_name, false)
    end

    it 'camelcases them' do
      expect(parameters).to eq(template_parameters: {'VpcId' => 'vpc-xxxxxx'}, compile_time_parameters: {})
    end
  end

  def file_mock(file_name, exists_return, read_return = nil)
    allow(File).to receive(:exists?).with(file_name).and_return(exists_return)
    allow(File).to receive(:read).with(file_name).and_return(read_return) if read_return
  end

end
