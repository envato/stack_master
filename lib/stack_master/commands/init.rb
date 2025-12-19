require "erb"

module StackMaster
  module Commands
    class Init
      include Command

      def initialize(options, region, stack_name)
        super(nil, nil, options)
        @region = region
        @stack_name = stack_name
      end

      def perform
        return unless check_files

        create_stack_master_yml
        create_stack_json_yml
        create_parameters_yml
      end

      private

      def check_files
        @stack_master_filename = "stack_master.yml"
        @stack_json_filename = "templates/#{@stack_name}.json"
        @parameters_filename = File.join("parameters", "#{@stack_name}.yml")
        @region_parameters_filename = File.join("parameters", @region, "#{@stack_name}.yml")

        if !@options.overwrite
          [@stack_master_filename, @stack_json_filename, @parameters_filename,
           @region_parameters_filename].each do |filename|
            next unless File.exist?(filename)

            StackMaster.stderr.puts("Aborting: #{filename} already exists. Use --overwrite to force overwriting file.")
            return false
          end
        end
        true
      end

      def create_stack_json_yml
        StackMaster.stdout.puts "Writing #{@stack_json_filename}"
        FileUtils.mkdir_p(File.dirname(@stack_json_filename))
        IO.write(@stack_json_filename, stack_json_output)
      end

      def stack_json_output
        render ERB.new(File.read(stack_json_template))
      end

      def stack_json_template
        File.join(StackMaster.base_dir, "stacktemplates", "stack.json.erb")
      end

      def create_stack_master_yml
        StackMaster.stdout.puts "Writing #{@stack_master_filename}"
        IO.write("#{@stack_master_filename}", stack_master_yml_output)
      end

      def stack_master_yml_output
        render ERB.new(File.read(stack_master_template))
      end

      def stack_master_template
        File.join(StackMaster.base_dir, "stacktemplates", "stack_master.yml.erb")
      end

      def create_parameters_yml
        StackMaster.stdout.puts "Writing #{@parameters_filename}"
        StackMaster.stdout.puts "Writing #{@region_parameters_filename}"
        FileUtils.mkdir_p("parameters/#{@region}")
        IO.write(@parameters_filename, parameter_stack_name_yml_output)
        IO.write(@region_parameters_filename, parameter_region_yml_output)
      end

      def parameter_stack_name_yml_output
        File.read(parameter_stack_name_template)
      end

      def parameter_region_yml_output
        File.read(parameter_region_template)
      end

      def parameter_stack_name_template
        File.join(StackMaster.base_dir, "stacktemplates", "parameter_stack_name.yml")
      end

      def parameter_region_template
        File.join(StackMaster.base_dir, "stacktemplates", "parameter_region.yml")
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
