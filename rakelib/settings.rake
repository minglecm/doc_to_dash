require 'pp'
require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)

desc "Show the project's settings"
task :settings do
  pp Settings
end