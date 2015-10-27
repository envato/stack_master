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
        create_parameters_yml
      end

      private

      def create_stack_master_yml
        puts "Writing stack_master.yml"
        IO.write("stack_master.yml", stack_master_yml_output)
      end

      def stack_master_yml_output
        renderer = ERB.new(File.read(stack_master_template))
        binding = InitBinding.new(region: @region, stack_name: @stack_name).get_binding
        renderer.result(binding)
      end

      def stack_master_template
        File.join(StackMaster.base_dir, "templates", "stack_master.yml.erb")
      end

      def create_parameters_yml
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
