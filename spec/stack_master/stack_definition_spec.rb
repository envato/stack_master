RSpec.describe StackMaster::StackDefinition do
  subject(:stack_definition) do
    StackMaster::StackDefinition.new(
      region: region,
      region_alias: region_alias,
      stack_name: stack_name,
      raw_stack_name: raw_stack_name,
      template: template,
      tags: tags,
      base_dir: base_dir)
  end

  let(:region) { 'us-east-1' }
  let(:region_alias) { 'us-east-1' }
  let(:stack_name) { 'production_stack_name' }
  let(:raw_stack_name) { 'stack_name' }
  let(:template) { 'template.json' }
  let(:tags) { {'environment' => 'production'} }
  let(:base_dir) { '/base_dir' }

  it 'has default and region specific parameter file locations' do
    expect(stack_definition.parameter_files).to eq([
      "/base_dir/parameters/#{raw_stack_name}.yml",
      "/base_dir/parameters/#{region}/#{raw_stack_name}.yml"
    ])
  end

  context 'with additional parameter lookup dirs' do
    before do
      stack_definition.send(:additional_parameter_lookup_dirs=, ['production'])
    end

    it 'includes a parameter lookup dir for it' do
      expect(stack_definition.parameter_files).to eq([
        "/base_dir/parameters/#{raw_stack_name}.yml",
        "/base_dir/parameters/#{region}/#{raw_stack_name}.yml",
        "/base_dir/parameters/production/#{raw_stack_name}.yml"
      ])
    end
  end

  context 'if a region alias is specified' do
    let(:region_alias) { 'staging' }

    it 'has default, alias, and region specific parameter file locations' do
      expect(stack_definition.parameter_files).to eq([
        "/base_dir/parameters/#{raw_stack_name}.yml",
        "/base_dir/parameters/#{region_alias}/#{raw_stack_name}.yml",
        "/base_dir/parameters/#{region}/#{raw_stack_name}.yml",
      ])
    end
  end
end
