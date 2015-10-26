module StackMaster
  module Config
    class StackDefinition
      include Virtus.value_object(strict: true, required: false)

      values do
        attribute :region, String
        attribute :stack_name, String
        attribute :template, String
        attribute :tags, Hash
        attribute :parameter_files, Array[String]
      end
    end
  end
end
