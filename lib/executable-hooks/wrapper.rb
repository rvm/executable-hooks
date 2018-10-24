# install / uninstall wrapper
require 'fileutils'
require 'rubygems'
require 'executable-hooks/specification'

module ExecutableHooks
  class Wrapper
    def self.wrapper_name
      'ruby_executable_hooks'
    end

    def self.expanded_wrapper_name
      Gem.default_exec_format % self.wrapper_name
    end

    attr_reader :options

    def initialize(options)
      @options = options || RegenerateBinstubsCommand.default_install_options
    end

    def install
      @bindir = options[:bin_dir] if options[:bin_dir]
      ensure_custom_shebang

      executable_hooks_spec = ExecutableHooks::Specification.find

      if executable_hooks_spec
        install_from( executable_hooks_spec.full_gem_path )
      end
    end

    def install_from(full_gem_path)
      wrapper_path = File.expand_path( "bin/#{self.class.wrapper_name}", full_gem_path )
      bindir       = calculate_bindir(options)
      destination  = calculate_destination(bindir)

      if File.exist?(wrapper_path) && !same_file(wrapper_path, destination)
        FileUtils.mkdir_p(bindir) unless File.exist?(bindir)
        # exception based on Gem::Installer.generate_bin
        raise Gem::FilePermissionError.new(bindir) unless File.writable?(bindir)
        FileUtils.cp(wrapper_path, destination)
        File.chmod(0775, destination)
      end
    end

    def same_file(file1, file2)
      File.exist?(file1) && File.exist?(file2) &&
        File.read(file1) == File.read(file2)
    end
    private :same_file

    def uninstall
      destination = calculate_destination(calculate_bindir(options))
      FileUtils.rm_f(destination) if File.exist?(destination)
    end

    def calculate_bindir(options)
      return options[:bin_dir] if options[:bin_dir]
      Gem.respond_to?(:bindir,true) ? Gem.send(:bindir) : File.join(Gem.dir, 'bin')
    end

    def calculate_destination(bindir)
      File.expand_path(self.class.expanded_wrapper_name, bindir)
    end


    def ensure_custom_shebang
      expected_shebang = "$env #{self.class.expanded_wrapper_name}"

      Gem.configuration[:custom_shebang] ||= expected_shebang

      if Gem.configuration[:custom_shebang] != expected_shebang
        warn("
Warning:
    Found    custom_shebang: '#{Gem.configuration[:custom_shebang]}',
    Expected custom_shebang: '#{expected_shebang}',
this can potentially break 'executable-hooks' and gem executables overall!
Check your '~/.gemrc' and '/etc/gemrc' for 'custom_shebang' and remove it.
")
      end
    end

  end
end
