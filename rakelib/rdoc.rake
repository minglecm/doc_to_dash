# RDoc http://rdoc.rubyforge.org/
# Ruby Documentation System

# Will generate documentation from all .rb files under RDOC_SOURCE_DIRS and
# any README* files and any *.rdoc files.
# If a VERSION or version.rb file exists, will use the version found in the file in the documentation.
# Note, a VERSION file should be a file that contains just a version,
# while version.rb should contain a 'VERSION = "\d\S+"' line.

require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)
# Uses these settings:
# * Settings[:app_name]
# * Settings[:source_dirs]

# Will output HTML to the ./rdoc directory

# rake clobber_rdoc        # Remove RDoc HTML files
# rake rdoc                # Build RDoc HTML files
# rake rerdoc              # Rebuild RDoc HTML files

# add to your .gemspec:
#   gem.add_development_dependency('rdoc')
# or add to your Gemfile:
#   gem 'rdoc'


begin
  require 'rdoc/task'
  require File.expand_path('version.rb', File.dirname(__FILE__))

  desc 'Remove the generated documentation'
  task :clean do
    puts "removing rdoc documentation"
    FileUtils.rm_rf File.expand_path(Settings[:rdoc_output_dir], Rake.application.original_dir)
  end

  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = Settings[:rdoc_output_dir]
    rdoc.title = "#{Settings[:app_name]} #{Version.version_get}".strip
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('**/*.rdoc')
    rdoc.rdoc_files.include("{#{Settings[:source_dirs].join(',')}}/**/*.rb")
  end
rescue LoadError
  warn "rdoc not available, rdoc tasks not provided."
rescue Exception => ex
  warn "#{ex.to_s}, rdoc tasks not provided."
end
