# Rubygems executable hooks

Add next rubygems plugin support for executables.

## Usage

Install the gem:

    gem install executable-hooks

In gem `lib` dir create `rubygems_executable_plugin.rb`:

    Gem.execute do |original_file|
      warn("Executing: #{original_file}")
    end

Generate and install the new gem with executable hook.

Now try it:

    gem install haml
    haml --version

Returns:

    Executing: /home/mpapis/.rvm/gems/ruby-1.8.7-p374-new1/bin/haml
    Haml 4.0.3
