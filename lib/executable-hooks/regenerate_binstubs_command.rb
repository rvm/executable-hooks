require 'rubygems/command_manager'
require 'rubygems/installer'
require 'rubygems/version'
require 'executable-hooks/wrapper'

class RegenerateBinstubsCommand < Gem::Command
  def initialize
    super 'regenerate_binstubs', 'Re run generation of executable wrappers for gems.'
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
    ExecutableHooks::Wrapper.install
    execute_no_wrapper
  end

  def execute_no_wrapper
    require 'executable-hooks/installer'
    name = get_one_optional_argument || ''
    specs = installed_gems.select{|spec| spec.name =~ /^#{name}/i }
    specs.each do |spec|
      unless spec.executables.empty?
        try_to_fix_binstubs(spec) or
        try_to_install_binstubs(spec) or
        $stderr.puts "##{spec.name} #{spec.version} not found in GEM_PATH"
      end
    end
  end

  private

  def try_to_fix_binstubs(spec)
    executable_paths =
    spec.executables.map do |executable|
      path = expanded_bin_paths.detect{|path| File.exist?(File.join(path, executable)) }
      File.join(path, executable) if path
    end
    return false if executable_paths.include?(nil) # not found
    executable_shebangs =
    executable_paths.map do |path|
      [path, File.readlines(path).map(&:chomp)]
    end
    return false if executable_shebangs.detect{|path, lines| !lines[0] =~ /^#!\// }
    puts "#{spec.name} #{spec.version}"
    executable_mode = 0111
    executable_shebangs.map do |path, lines|
      lines[0] = "#!#{ExecutableHooksInstaller.env_path} #{ExecutableHooks::Wrapper.expanded_wrapper_name}"
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
      paths
    end
  end

  def try_to_install_binstubs(spec)
    org_gem_path = expanded_gem_paths.find{|path|
      File.exists? File.join path, 'gems', spec.full_name
    } || Gem.dir
    cache_gem = File.join(org_gem_path, 'cache', spec.file_name)
    if File.exist? cache_gem
      puts "#{spec.name} #{spec.version}"
      inst = Gem::Installer.new Dir[cache_gem].first, :wrappers => true, :force => true, :install_dir => org_gem_path
      ExecutableHooksInstaller.bundler_generate_bin(inst)
    else
      false
    end
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
