module StackMaster
  class TemplatePatcher
    TemplatePatchingFailed = Class.new(RuntimeError)

    def self.patch(template, template_body, patches)
      return template_body unless patches && !patches.empty?

      output = TemplateUtils.template_hash(template_body)

      patches.each do |patch|
        output = patch.apply(output)
      end

      TemplateUtils.unhash_template(output, TemplateUtils.identify_template_format(template_body))
    rescue StandardError => e
      raise TemplatePatchingFailed, "#{e.class.name} patching #{template}: #{e.message}", e.backtrace
    end

    def self.load_json_patches(patch_files)
      patch_files.map do |path|
        patch_set = YAML.load(File.read(path))
        Hana::Patch.new(patch_set)
      end
    end
  end
end
