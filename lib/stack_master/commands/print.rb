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
        parameter_hash = ParameterLoader.load(@stack_definition.parameter_files)
        compile_time_parameters = ParameterResolver.resolve(@config, @stack_definition, parameter_hash[:compile_time_parameters])
        StackMaster.stdout.puts StackMaster::TemplateCompiler.compile(
          @config,
          @stack_definition.template_file_path,
          compile_time_parameters,
          @stack_definition.compiler_options
        )
      end
    end
  end
end
