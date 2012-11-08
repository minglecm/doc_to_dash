
require 'versionomy'
require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)

# This module provides methods for interacting with your version file.  The version
# file may be either the bundler standard of version.rb (which defines a constant VERSION within a module)
# or the jeweler standard of VERSION (which contains just a version number).
#
# Uses these settings:
#
#   * Settings[:source_dirs]
module Version
  # The regex for extracting the version from a version.rb file
  VERSION_REGEX = /VERSION\s*=\s*[\"\']?(\d[^\"\']*)[\"\']?/m

  # Get the paths to all the version.rb files
  # @return [Array<String>] relative paths to version.rb files
  def self.versionrb_filenames
    Dir["#{Rake.application.original_dir}/{#{Settings[:source_dirs].join(',')}}/**/version.rb"]
  end

  # Get the paths to all the VERSION files
  # @return [Array<String>] relative paths to VERSION files
  def self.version_filenames
    Dir["#{Rake.application.original_dir}**/VERSION"]
  end

  # Get the application's version from either version.rb or VERSION file
  # @return [String] the version
  def self.version_get
    versionrb_filenames.each do |version_file|
      str = IO.read(version_file)
      if str =~ VERSION_REGEX
        return $1
      end
    end
    version_filenames.each do |version_file|
      return IO.read(version_file).strip
    end
    'not found'
  end

  # Set the application version to the given version.  Will try to set version.rb and VERSION files.
  # @param [String] new_version the new version for the application
  # @return [String] the application's new version
  def self.version_set(new_version)
    versionrb_filenames.each do |version_file|
      str = IO.read(version_file)
      if str =~ VERSION_REGEX
        old_version = $1
        File.open(version_file, 'w') {|f| f.puts str.gsub(old_version, new_version)}
      end
    end
    version_filenames.each do |version_file|
      File.open(version_file, 'w') {|f| f.puts new_version}
    end
    new_version
  end

  # Bump the application's version.  The block is given the current version that it then bumps and returns.
  # The returned value is then used to set the version in all the version.rb and VERSION files in the project.
  # @param [Proc] block is pass the current version and returns the new version.
  # @return [String] the application's new version
  def self.version_bump(&block)
    old_version = Versionomy.parse version_get
    new_version = block.call(old_version).to_s
    version_set new_version
  end
end

