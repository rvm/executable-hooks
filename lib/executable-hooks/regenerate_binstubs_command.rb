require 'rubygems/command_manager'
require 'rubygems/installer'
require 'rubygems/version'
require 'executable-hooks/wrapper'

class RegenerateBinstubsCommand < Gem::Command
  def self.default_install_options
    require 'rubygems/commands/install_command'
    Gem::Command.extra_args = Gem.configuration[:gem]
    config_args = Gem.configuration[:install]
    config_args =
      case config_args
      when String
        config_args.split ' '
      else
        Array(config_args)
      end
    Gem::Command.add_specific_extra_args 'install', config_args
    ic = Gem::Commands::InstallCommand.new
    ic.handle_options ["install"]
    ic.options
  end

  def initialize
    super 'regenerate_binstubs', 'Re run generation of executable wrappers for gems.'

    add_option(:"Install/Update", '-i', '--install-dir DIR',
      'Gem repository directory to get installed',
      'gems') do |value, options|
      options[:install_dir] = File.expand_path(value)
    end

    add_option(:"Install/Update", '-n', '--bindir DIR',
      'Directory where binary files are',
      'located') do |value, options|
      options[:bin_dir] = File.expand_path(value)
    end
  end

  def arguments # :nodoc:
    "STRING        start of gem name to regenerate binstubs"
  end

  def usage # :nodoc:
    "#{program_name} [STRING]"
  end

  def defaults_str # :nodoc:
    ""
  end

  def description # :nodoc:
    'Re run generation of executable wrappers for all gems. '+
    'Wrappers will be compatible with both rubygems and bundler. '+
    'The switcher is BUNDLE_GEMFILE environment variable, '+
    'when set it switches to bundler mode, when not set, '+
    'then the command will work as it was with pure rubygems.'
  end

  def execute
    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('2.0.0') then
      # https://github.com/rubygems/rubygems/issues/326
      puts "try also: gem pristine --binstubs"
    end
    ExecutableHooks::Wrapper.new(options).install
    execute_no_wrapper
  end

  def execute_no_wrapper(wrapper_name = ExecutableHooks::Wrapper.expanded_wrapper_name)
    require 'executable-hooks/installer'
    name = get_one_optional_argument || ''
    specs = installed_gems.select{|spec| spec.name =~ /^#{name}/i }
    specs.each do |spec|
      executables = spec.executables.reject{ |name| name == 'executable-hooks-uninstaller' }
      unless executables.empty?
        try_to_fix_binstubs(spec, executables, wrapper_name) or
        try_to_install_binstubs(spec) or
        $stderr.puts "##{spec.name} #{spec.version} not found in GEM_PATH"
      end
    end
  end

  private

  def try_to_fix_binstubs(spec, executables, wrapper_name)
    executable_paths =
    executables.map do |executable|
      path = expanded_bin_paths.detect{|bin_path| File.exist?(File.join(bin_path, executable)) }
      File.join(path, executable) if path
    end
    return false if executable_paths.include?(nil) # not found
    executable_shebangs =
    executable_paths.map do |path|
      [path, File.readlines(path).map{|l|l.chomp}]
    end
    return false if executable_shebangs.detect{|path, lines| !(lines[0] =~ /^#!\//) }
    puts "#{spec.name} #{spec.version}"
    executable_mode = 0111
    executable_shebangs.map do |path, lines|
      lines[0] = "#!#{ExecutableHooksInstaller.env_path} #{wrapper_name}"
      File.open(path, "w") do |file|
        file.puts(lines)
      end
      mode = File.stat(path).mode
      File.chmod(mode | executable_mode, path) if mode & executable_mode != executable_mode
    end
  end

  def expanded_bin_paths
    @expanded_bin_paths ||= begin
      paths = expanded_gem_paths.map{|path| File.join(path, "bin") }
      paths << RbConfig::CONFIG["bindir"]
      # TODO: bindir from options?
      paths
    end
  end

  def try_to_install_binstubs(spec)
    org_gem_path = options[:install_dir] || existing_gem_path(spec.full_name) || Gem.dir
    cache_gem = File.join(org_gem_path, 'cache', spec.file_name)
    if File.exist? cache_gem
      puts "#{spec.name} #{spec.version}"
      inst = Gem::Installer.new Dir[cache_gem].first, :wrappers => true, :force => true, :install_dir => org_gem_path, :bin_dir => options[:bin_dir]
      ExecutableHooksInstaller.bundler_generate_bin(inst)
    else
      false
    end
  end

  def existing_gem_path(full_name)
    expanded_gem_paths.find{|path| File.exists?(File.join(path, 'gems', full_name))}
  end

  def expanded_gem_paths
    @expanded_gem_paths ||=
    Gem.path.map do |path|
      paths = [path]
      while File.symlink?(path)
        path = File.readlink(path)
        paths << path
      end
      paths
    end.flatten
  end

  def installed_gems
    if Gem::VERSION > '1.8' then
      Gem::Specification.to_a
    else
      Gem.source_index.map{|name,spec| spec}
    end
  end
end
