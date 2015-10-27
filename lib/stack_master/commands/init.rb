module StackMaster
  module Commands
    class Init
      include Command

      def initialize(region, stack_name)
        @region = region
        @stack_name = stack_name
      end

      def perform
        create_stack_master_yml
        create_stack_json_yml
        create_parameters_yml
      end

      private

      def create_stack_json_yml
        filename = "templates/#{@stack_name}.json"
        puts "Writing #{filename}"
        FileUtils.mkdir_p(File.dirname(filename))
        IO.write(filename, stack_json_output)
      end

      def stack_json_output
        render ERB.new(File.read(stack_json_template))
      end

      def stack_json_template
        File.join(StackMaster.base_dir, "ymltemplates", "stack.json.erb")
      end

      def create_stack_master_yml
        puts "Writing stack_master.yml"
        IO.write("stack_master.yml", stack_master_yml_output)
      end

      def stack_master_yml_output
        render ERB.new(File.read(stack_master_template))
      end

      def stack_master_template
        File.join(StackMaster.base_dir, "ymltemplates", "stack_master.yml.erb")
      end

      def create_parameters_yml
        stack_file = File.join("parameters", "#{underscored_stack_name}.yml")
        region_stack_file = File.join("parameters", @region, "#{underscored_stack_name}.yml")
        puts "Writing #{stack_file}"
        puts "Writing #{region_stack_file}"
        FileUtils.mkdir_p("parameters/#{@region}")
        IO.write(stack_file, parameter_stack_name_yml_output)
        IO.write(region_stack_file, parameter_region_yml_output)
      end

      def parameter_stack_name_yml_output
        File.read(parameter_stack_name_template)
      end

      def parameter_region_yml_output
        File.read(parameter_region_template)
      end

      def parameter_stack_name_template
        File.join(StackMaster.base_dir, "ymltemplates", "parameter_stack_name.yml")
      end

      def parameter_region_template
        File.join(StackMaster.base_dir, "ymltemplates", "parameter_region.yml")
      end

      def underscored_stack_name
        @stack_name.gsub('-', '_')
      end

      def render(renderer)
        binding = InitBinding.new(region: @region, stack_name: @stack_name).get_binding
        renderer.result(binding)
      end

      class InitBinding
        def initialize(region:, stack_name:)
          @region = region
          @stack_name = stack_name
        end

        attr_reader :region, :stack_name
      end
    end
  end
end
