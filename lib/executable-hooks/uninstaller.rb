require 'executable-hooks/wrapper'
require 'executable-hooks/regenerate_binstubs_command'

module ExecutableHooks
  def self.uninstall
    Gem.configuration[:custom_shebang] = '$env ruby'
    RegenerateBinstubsCommand.new.execute_no_wrapper
    Wrapper.uninstall
  end
end
