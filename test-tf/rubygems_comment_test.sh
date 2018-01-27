gem install executable-hooks-$(awk -F'"' '/VERSION/{print $2}' < lib/executable-hooks/version.rb).gem --development
# match=/installed/

gem install haml            # match=/installed/
head -n 1 $(which haml)     # match=/ruby_executable_hooks/
which ruby_executable_hooks # status=0

gem list                     # match=/haml/
executable-hooks-uninstaller # match=/haml/

head -n 1 $(which haml)      # match!=/ruby_executable_hooks/
which ruby_executable_hooks  # status=1

gem uninstall -x haml        # match=/Successfully uninstalled/
