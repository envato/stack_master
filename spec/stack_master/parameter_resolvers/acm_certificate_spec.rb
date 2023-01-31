RSpec.describe StackMaster::ParameterResolvers::AcmCertificate do
  let(:config) { double(base_dir: '/base') }
  let(:stack_definition) { double(stack_name: 'mystack', region: 'us-east-1') }
  subject(:resolver) { described_class.new(config, stack_definition) }
  let(:acm) { Aws::ACM::Client.new }

  before do
    allow(Aws::ACM::Client).to receive(:new).and_return(acm)
  end

  context 'when a certificate is found' do
    before do
      acm.stub_responses(
        :list_certificates,
        {
          certificate_summary_list: [
            { certificate_arn: 'arn:aws:acm:us-east-1:12345:certificate/abc', domain_name: 'abc' },
            { certificate_arn: 'arn:aws:acm:us-east-1:12345:certificate/def', domain_name: 'def' }
          ]
        }
      )
    end

    it 'returns the certificate' do
      expect(resolver.resolve('def')).to eq 'arn:aws:acm:us-east-1:12345:certificate/def'
    end
  end

  context 'when no certificate is found' do
    before do
      acm.stub_responses(:list_certificates, { certificate_summary_list: [] })
    end

    it 'raises an error' do
      expect { resolver.resolve('def') }.to raise_error(
        StackMaster::ParameterResolvers::AcmCertificate::CertificateNotFound,
        'Could not find certificate def in us-east-1'
      )
    end
  end
end
