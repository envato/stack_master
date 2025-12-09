RSpec.describe StackMaster::SparkleFormation::CompileTime::StateBuilder do
  let(:definitions) { { ip: { type: :string }, size: { type: :number } } }
  let(:ip) { '10.0.0.0' }
  let(:size) { nil }
  let(:parameters) { { 'Ip' => ip } }
  let(:ip_builder) { instance_double(StackMaster::SparkleFormation::CompileTime::ValueBuilder) }
  let(:size_builder) { instance_double(StackMaster::SparkleFormation::CompileTime::ValueBuilder) }

  subject { described_class.new(definitions, parameters) }

  before(:each) do
    allow(StackMaster::SparkleFormation::CompileTime::ValueBuilder)
      .to receive(:new)
      .with({ type: :string }, ip)
      .and_return(ip_builder)
    allow(StackMaster::SparkleFormation::CompileTime::ValueBuilder)
      .to receive(:new)
      .with({ type: :number }, size)
      .and_return(size_builder)
    allow(ip_builder).to receive(:build).and_return(ip)
    allow(size_builder).to receive(:build).and_return(size)
  end

  describe '#build' do
    it 'should create state' do
      expected = { ip: '10.0.0.0', size: nil }
      expect(subject.build).to eq(expected)
    end
  end
end
