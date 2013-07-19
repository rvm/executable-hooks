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
        if ENV['RUBYGEMS_LOAD_ALL_PLUGINS']
          load_plugin_files find_files('rubygems_executable_plugin', false)
        else
          begin
            load_plugin_files find_latest_files('rubygems_executable_plugin', false)
          rescue NoMethodError
            load_plugin_files find_files('rubygems_executable_plugin', false)
          end
        end
      rescue ArgumentError, NoMethodError
        # old rubygems
        plugins = find_files('rubygems_executable_plugin')

        plugins.each do |plugin|

          # Skip older versions of the GemCutter plugin: Its commands are in
          # RubyGems proper now.

          next if plugin =~ /gemcutter-0\.[0-3]/

          begin
            load plugin
          rescue ::Exception => e
            details = "#{plugin.inspect}: #{e.message} (#{e.class})"
            warn "Error loading RubyGems plugin #{details}"
          end
        end
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
