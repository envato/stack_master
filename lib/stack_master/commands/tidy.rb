module StackMaster
  module Commands
    class Tidy
      include Command
      include StackMaster::Commands::TerminalHelper

      def perform
        used_templates = []
        used_parameter_files = []

        templates = Set.new(find_templates)
        parameter_files = Set.new(find_parameter_files)

        status = @config.stacks.each do |stack_definition|
          parameter_files.subtract(stack_definition.parameter_files_from_globs)
          template = File.absolute_path(stack_definition.template_file_path)

          next unless template

          templates.delete(template)

          next if File.exist?(template)

          StackMaster.stdout.puts(
            "Stack \"#{stack_definition.stack_name}\" in \"#{stack_definition.region}\" " \
            "missing template \"#{rel_path(template)}\""
          )
        end

        templates.each do |path|
          StackMaster.stdout.puts "#{rel_path(path)}: no stack found for this template"
        end

        parameter_files.each do |path|
          StackMaster.stdout.puts "#{rel_path(path)}: no stack found for this parameter file"
        end
      end

      def rel_path(path)
        Pathname.new(path).relative_path_from(Pathname.new(@config.base_dir))
      end

      def find_templates
        # TODO: Inferring default template directory based on the behaviour in
        # stack_definition.rb. For some configurations (eg, per-region
        # template directories) this won't find the right directory.
        template_dir = @config.template_dir || File.join(@config.base_dir, 'templates')

        templates = Dir.glob(File.absolute_path(File.join(template_dir, '**', "*.{rb,yaml,yml,json}")))
        dynamics_dir = File.join(template_dir, 'dynamics')

        # Exclude sparkleformation dynamics
        # TODO: Should this filter out anything with 'dynamics', not just the first
        # subdirectory?
        templates = templates.select do |path|
          !path.start_with?(dynamics_dir)
        end

        templates
      end

      def find_parameter_files
        Dir.glob(File.absolute_path(File.join(@config.base_dir, "parameters", "*.{yml,yaml}")))
      end
    end
  end
end
