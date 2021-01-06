# Releasing

- update `lib/executable-hooks/version.rb` with new version (use semantic versioning)
- update `CHANGELOG.md` with changes relevant to running hooks
- git commit changes with version as comment
- git tag version
- `git push`
- `git push --tags`
- use ruby 1.8.7 for releasing `rvm use 1.8.7 --install`
- `gem build executable-hooks.gemspec`
- `gem push executable-hooks-1.6.1.gem` - update version
