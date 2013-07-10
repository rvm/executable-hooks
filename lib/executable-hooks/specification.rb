module ExecutableHooks
  module Specification
    def self.find
      @executable_hooks_spec ||=
        if Gem::Specification.respond_to?(:find_by_name)
          Gem::Specification.find_by_name("executable-hooks")
        else
          Gem.source_index.find_name("executable-hooks").last
        end
    rescue Gem::LoadError
      nil
    end
    def self.version
      find ? find.version.to_s : nil
    end
  end
end
