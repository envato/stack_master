module StackMaster
  module Commands
    class Print
      include Command
      include Commander::UI

      def initialize(config, stack_definition, options = {})
        @config = config
        @stack_definition = stack_definition
      end

      def perform
        StackMaster.stdout.puts StackMaster::TemplateCompiler.compile(
          @config,
          @stack_definition.template_file_path,
          nil,
          @stack_definition.compiler_options
        )
      end
    end
  end
end
