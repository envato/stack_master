module StackMaster
  module Commands
    class DepTree
      include Command
      include Commander::UI

      def perform
        @parent_stacks = []
        stack_tree = {}
        stack_tree[top_stack_name] = process_tree(top_stack_name)
        print_tree(top_stack_name, stack_tree[top_stack_name])
      end

      private

      def print_tree(name, tree, level=0)
        StackMaster.stdout.puts ('   ' * [0, level-1].max + ' ↳ ' * [level, 1].min + ' ' + name)
        tree.each do |k, subtree|
          print_tree(k, subtree, level+1)
        end
      end

      def process_tree(stack_name)
        if @parent_stacks.include? stack_name
          raise "cycle"
        end
        @parent_stacks << stack_name
        stack_params = get_dependency_stacks(stack_name)
        stack_params.map(&:first).uniq.map do |child_stack_name|
          [child_stack_name, process_tree(child_stack_name)]
        end.to_h
      ensure
        @parent_stacks.pop
      end

      def get_parameters(stack_name)
        stack_definition = @config.find_stack(region, stack_name)
        return nil if stack_definition.nil?

        ParameterLoader.load(parameter_files: stack_definition.all_parameter_files)
      end

      def get_dependency_stacks(stack_name)
        parameters = get_parameters(stack_name)
        return [] if parameters.nil?

        [].tap do |stack_deps|
          parameters[:template_parameters].each do |k,v|
            if v.is_a?(Hash) && v.has_key?("stack_output")
              stack_deps << v["stack_output"].split('/')
            end
          end
        end
      end

      def top_stack_name
        @stack_definition.stack_name
      end
      def region
        @stack_definition.region
      end
    end
  end
end
