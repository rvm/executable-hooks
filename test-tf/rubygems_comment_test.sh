gem install executable-hooks-$(awk -F'"' '/VERSION/{print $2}' < lib/executable-hooks/version.rb).gem --development
# match=/installed/
wrapper_name=$(ruby -I ./lib/ -r executable-hooks/wrapper -e "puts ExecutableHooks::Wrapper.expanded_wrapper_name")

gem install haml -v "<5"     # match=/installed/
head -n 1 $(which haml )     # match=/ruby_executable_hooks/
which ${wrapper_name}        # status=0

gem list                     # match=/haml/
executable-hooks-uninstaller # match=/haml/

head -n 1 $(which haml)      # match!=/ruby_executable_hooks/
which ${wrapper_name}        # status=1

gem uninstall -x haml        # match=/Successfully uninstalled/
