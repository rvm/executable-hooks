#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

Kernel.load(File.expand_path("../lib/executable-hooks/version.rb", __FILE__))

Gem::Specification.new do |s|
  s.name        = "executable-hooks"
  s.version     = ExecutableHooks::VERSION
  s.authors     = ["Michal Papis"]
  s.email       = ["mpapis@gmail.com"]
  s.homepage    = "https://github.com/mpapis/executable-hooks"
  s.summary     = %q{
    Hook into rubygems executables allowing extra actions to be taken before executable is run.
  }

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = %w( executable-hooks-uninstaller )

  s.add_development_dependency "tf"
  #s.add_development_dependency "smf-gem"
end
