module StackMaster
  module ParameterResolvers
    class AcmCertificate < Resolver
      CertificateNotFound = Class.new(StandardError)

      def initialize(config, stack_definition)
        @config = config
        @stack_definition = stack_definition
      end

      def resolve(domain_name)
        cert_arn = find_cert_arn_by_domain_name(domain_name)
        unless cert_arn
          raise CertificateNotFound, "Could not find certificate #{domain_name} in #{@stack_definition.region}"
        end

        cert_arn
      end

      private

      def all_certs
        certs = []
        next_token = nil
        client = Aws::ACM::Client.new({ region: @stack_definition.region })
        loop do
          resp = client.list_certificates({ certificate_statuses: ['ISSUED'], next_token: next_token })
          certs << resp.certificate_summary_list
          next_token = resp.next_token
          break if next_token.nil?
        end
        certs.flatten
      end

      def find_cert_arn_by_domain_name(domain_name)
        all_certs.map { |c| c.certificate_arn if c.domain_name == domain_name }.compact.first
      end
    end
  end
end
