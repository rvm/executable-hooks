#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

Kernel.load(File.expand_path("../lib/executable-hooks/version.rb", __FILE__))

Gem::Specification.new do |s|
  s.name        = "executable-hooks"
  s.version     = ExecutableHooks::VERSION
  s.license     = 'Apache 2.0'
  s.authors     = ["Michal Papis"]
  s.email       = ["mpapis@gmail.com"]
  s.homepage    = "https://github.com/mpapis/executable-hooks"
  s.summary     = %q{
    Hook into rubygems executables allowing extra actions to be taken before executable is run.
  }
  s.post_install_message = <<-MESSAGE
# In case of problems run the following command to update binstubs:
    gem regenerate_binstubs
  MESSAGE


  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.extensions  = %w( ext/wrapper_installer/extconf.rb )
  s.executables = %w( executable-hooks-uninstaller )

  s.add_development_dependency "tf", "~>0.4"
end
