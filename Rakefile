require "bundler/gem_tasks"

# define our project's environment by overriding the Settings defaults
require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)

Settings[:app_name]             = 'doc_to_dash'
Settings[:doc_dir]              = 'doc'
Settings[:rdoc_output_dir]      = 'doc/rdoc'
Settings[:yard_output_dir]      = 'doc/ydoc'
Settings[:source_dirs]          = %w{ lib }
Settings[:coverage_dirs]        = %w{ lib spec }
Settings[:test_dirs]            = %w{ spec }
