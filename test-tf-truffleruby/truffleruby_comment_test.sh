gem install executable-hooks-$(awk -F'"' '/VERSION/{print $2}' < lib/executable-hooks/version.rb).gem --development
# match=/installed/

gem install haml -v "4.0.7"    # match=/installed/
haml_bin=$(which haml )
head -n 1 $haml_bin            # match=/ruby_executable_hooks/

## simulate truffleruby style binary with shell code mixed in
## \043 - is a # ... somehow it breaks tf
( head -n 1 $haml_bin; echo -e 'echo $HOME\n\043!ruby'; tail -n +2 $haml_bin ) > $haml_bin.new
mv $haml_bin.new $haml_bin
chmod +x $haml_bin

haml _4.0.7_ -v                # match=/4.0.7/

gem uninstall -x haml -v 4.0.7 # match=/Successfully uninstalled/
