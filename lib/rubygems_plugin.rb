# Simulate require_relative - it's required as the plugin can be called in wrong version or from bundler.
require File.expand_path('../executable-hooks/specification.rb', __FILE__)

called_path, called_version = __FILE__.match(/^(.*\/executable-hooks-([^\/]+)\/lib).*$/)[1..2]

# continue only if loaded and called versions all the same, and not shared gems disabled in bundler
if
  ( $:.include?(called_path) || ExecutableHooks::Specification.version == called_version ) and
  ( !defined?(Bundler) || ( defined?(Bundler) && Bundler::SharedHelpers.in_bundle? && !Bundler.settings[:disable_shared_gems]) )

  require 'rubygems/version'
  require 'executable-hooks/wrapper'

  # Set the custom_shebang if user did not set one
  Gem.pre_install do |gem_installer|
    options = if gem_installer.methods.map{|m|m.to_s}.include?('options')
      gem_installer.options
    end
    ExecutableHooks::Wrapper.new(options).install
  end

  if Gem::Version.new(Gem::VERSION) < Gem::Version.new('2.0') then
    # Add custom_shebang support to rubygems
    require 'executable-hooks/installer'
  end

  require 'executable-hooks/regenerate_binstubs_command'
  Gem::CommandManager.instance.register_command :regenerate_binstubs
end
