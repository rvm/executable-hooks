Gem.execute do |original_file|
  warn("Executing: #{original_file}") if ENV.key?('ExecutableHooks_DEBUG')
end
