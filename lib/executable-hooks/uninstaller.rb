require 'executable-hooks/wrapper'
require 'executable-hooks/regenerate_binstubs_command'

module ExecutableHooks
  def self.uninstall
    Gem.configuration[:custom_shebang] = "$env #{Gem.default_exec_format % "ruby"}"
    RegenerateBinstubsCommand.new.execute_no_wrapper
    Wrapper.uninstall
  end
end
