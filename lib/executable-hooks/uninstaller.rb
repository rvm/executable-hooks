require 'executable-hooks/wrapper'
require 'executable-hooks/regenerate_binstubs_command'
require 'rubygems/uninstaller'

module ExecutableHooks
  def self.uninstall
    Gem.configuration[:custom_shebang] = "$env #{Gem.default_exec_format % "ruby"}"
    options = RegenerateBinstubsCommand.default_install_options
    RegenerateBinstubsCommand.new.execute_no_wrapper("ruby")
    ExecutableHooks::Wrapper.new(options).uninstall
    options.merge!(:executables => true, :all => true, :ignore => true)
    Gem::Uninstaller.new("executable-hooks", options).uninstall
  end
end
