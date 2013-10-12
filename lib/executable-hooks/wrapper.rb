# install / uninstall wrapper
require 'fileutils'
require 'rubygems'
require 'executable-hooks/specification'

module ExecutableHooks
  module Wrapper
    def self.wrapper_name
      'ruby_executable_hooks'
    end
    def self.expanded_wrapper_name
      Gem.default_exec_format % self.wrapper_name
    end
    def self.bindir
      Gem.respond_to?(:bindir,true) ? Gem.send(:bindir) : File.join(Gem.dir, 'bin')
    end
    def self.destination
      File.expand_path( expanded_wrapper_name, bindir )
    end
    def self.ensure_custom_shebang
      expected_shebang = "$env #{expanded_wrapper_name}"

      Gem.configuration[:custom_shebang] ||= expected_shebang

      if Gem.configuration[:custom_shebang] != expected_shebang
        warn("
Warning:
    Found    custom_shebang: '#{Gem.configuration[:custom_shebang]}',
    Expected custom_shebang: '#{expected_shebang}',
this can potentially break 'executable-hooks' and gem executables overall!
")
      end
    end
    def self.install
      ensure_custom_shebang

      executable_hooks_spec = ExecutableHooks::Specification.find

      if executable_hooks_spec
        install_from( executable_hooks_spec.full_gem_path )
      end
    end

    def self.install_from(full_gem_path)
      wrapper_path = File.expand_path( "bin/#{wrapper_name}", full_gem_path )

      if File.exist?(wrapper_path) && !File.exist?(destination)
        FileUtils.mkdir_p(bindir) unless File.exist?(bindir)
        # exception based on Gem::Installer.generate_bin
        raise Gem::FilePermissionError.new(bindir) unless File.writable?(bindir)
        FileUtils.cp(wrapper_path, destination)
        File.chmod(0775, destination)
      end
    end
    def self.uninstall
      FileUtils.rm_f(destination) if File.exist?(destination)
    end
  end
end
