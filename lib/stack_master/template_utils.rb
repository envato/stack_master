module StackMaster
  module TemplateUtils
    MAX_TEMPLATE_SIZE = 51200
    MAX_S3_TEMPLATE_SIZE = 460800
    # Matches if the first non-whitespace character is a '{', handling cases
    # with leading whitespace and extra (whitespace-only) lines.
    JSON_IDENTIFICATION_PATTERN = Regexp.new('\A\s*{', Regexp::MULTILINE)

    extend self

    def identify_template_format(template_body)
      if template_body =~ JSON_IDENTIFICATION_PATTERN
        :json
      else
        :yaml
      end
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
