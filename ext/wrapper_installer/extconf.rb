# Fake building extension
File.open('Makefile', 'w') { |f| f.write("all:\n\ninstall:\n\n") }
File.open('make', 'w') do |f|
  f.write('#!/bin/sh')
  f.chmod(f.stat.mode | 0111)
end
File.open('wrapper_installer.so', 'w') {}
File.open('wrapper_installer.dll', 'w') {}
File.open('nmake.bat', 'w') { |f| }


# add the gem to load path
$: << File.expand_path("../../../lib", __FILE__)
# load the uninstaller
require 'executable-hooks/uninstaller'
# call the action
RegenerateBinstubsCommand.new.execute
# unload the path, what was required stays ... but there is that much we can do
$:.pop

# just in case - it worked
true
