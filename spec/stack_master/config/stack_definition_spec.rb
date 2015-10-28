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

  it 'has default and region specific parameter file locations' do
    expect(stack_definition.parameter_files).to eq([
      "/base_dir/parameters/#{stack_name}.yml",
      "/base_dir/parameters/#{region}/#{stack_name}.yml"
    ])
  end
end
