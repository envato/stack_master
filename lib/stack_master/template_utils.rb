module StackMaster
  module TemplateUtils
    MAX_TEMPLATE_SIZE = 51200
    MAX_S3_TEMPLATE_SIZE = 460800

    extend self

    def identify_template_format(template_body)
      return :json if template_body =~ /^{/x # ignore leading whitespaces
      :yaml
    end

    def template_hash(template_body=nil)
      return unless template_body
      template_format = identify_template_format(template_body)
      case template_format
      when :json
        JSON.parse(template_body)
      when :yaml
        YAML.load(template_body)
      end
    end

    def maybe_compressed_template_body(template_body)
      # Do not compress the template if it's not JSON because parsing YAML as a hash ignores
      # CloudFormation-specific tags such as !Ref
      return template_body if template_body.size <= MAX_TEMPLATE_SIZE || identify_template_format(template_body) != :json
      JSON.dump(template_hash(template_body))
    end
  end
end