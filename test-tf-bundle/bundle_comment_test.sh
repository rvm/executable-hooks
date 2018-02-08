gem install executable-hooks-$(awk -F'"' '/VERSION/{print $2}' < lib/executable-hooks/version.rb).gem --development
# match=/installed/
gem install rubygems-bundler bundler
# match=/installed/
gem install haml -v "4.0.7"  # match=/installed/
# match=/installed/

true TMPDIR:${TMPDIR:=/tmp}:
d=$TMPDIR/test-bundled
mkdir $d
pushd $d

NOEXEC=1 haml -v             # match=/4.0.7/

echo -e 'source "https://rubygems.org"\ngem "haml", "4.0.6"' > Gemfile
bundle install               # match=/haml 4.0.6/
NOEXEC=1 haml -v             # match=/4.0.6/

popd
rm -rf $d