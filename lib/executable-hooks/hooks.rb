module Gem
  @executables_hooks    ||= []

  class << self
    unless method_defined?(:execute)
      def execute(&hook)
        @executables_hooks << hook
      end

      attr_reader :executables_hooks
    end

    unless method_defined?(:load_executable_plugins)
      def load_executable_plugins
        load_plugin_files(find_files('rubygems_executable_plugin', false))
      end
    end
  end

  class ExecutableHooks
    def self.run(original_file)
      Gem.load_executable_plugins
      Gem.executables_hooks.each do |hook|
        hook.call(original_file)
      end
    end
  end
end
