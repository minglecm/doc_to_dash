# Version bump tasks
#
# These tasks are for interacting with your version file.  The version file may be either
# the bundler standard of version.rb (which defines a constant VERSION within a module)
# or the jeweler standard of VERSION (which contains just a version number).

# rake version:bump:patch  # bump the patch version

# add to your .gemspec:
#   gem.add_development_dependency('versionomy')
# or add to your Gemfile:
#   gem 'versionomy'

begin
  require File.expand_path('version.rb', File.dirname(__FILE__))

  namespace :version do
    desc 'reset version to 0.0.1'
    task :reset do
      puts Version.version_set '0.0.1'
    end

    desc 'get the current version'
    task :get do
      puts Version.version_get
    end

    namespace :bump do
      desc 'bump the major version'
      task :major do
        old_version = Version.version_get
        new_version = Version.version_bump {|version| version.bump(:major)}
        puts "updated version from #{old_version} to #{new_version}"
      end
      desc 'bump the minor version'
      task :minor do
        old_version = Version.version_get
        new_version = Version.version_bump {|version| version.bump(:minor)}
        puts "updated version from #{old_version} to #{new_version}"
      end
      desc 'bump the patch version'
      task :patch do
        old_version = Version.version_get
        new_version = Version.version_bump {|version| version.bump(:tiny)}
        puts "updated version from #{old_version} to #{new_version}"
      end
    end
  end
rescue LoadError => ex
  warn "versionomy not available, version bump tasks not provided.  #{ex.to_s}"
end
