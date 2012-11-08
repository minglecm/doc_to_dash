require File.expand_path('rakelib/settings.rb', Rake.application.original_dir)

# YARD documentation http://yardoc.org/
#
# These tasks are for using the yard documentation system.
# The source files are .rb files in the YARD_SOURCE_DIRS directories.
# The output is placed into your project's doc/app/ directory.
# Any .md.erb files are processed with ERB to create .md files before running yard.
# If you have a README.md file (maybe generated from a README.md.erb file), it is used as the documentations README
#
# rake clean               # remove the generated documentation
# rake doc                 # generate documentation
# rake markdown_erb        # convert .md.erb documentation to .md
# rake yard                # Generate YARD Documentation
#
# add to your .gemspec:
#   gem.add_development_dependency('yard')
#   gem.add_development_dependency('redcarpet')
# or add to your Gemfile:
#   gem 'yard'
#   gem 'redcarpet'
#
# if you want syntax highlighting via pygments (http://pygments.org)
#
# * install pygments
# * add the following to your .gemspec
#     gem.add_development_dependency('yard-pygmentsrb')
#     gem.add_development_dependency('pygments.rb')
#   or add to your Gemfile:
#     gem 'yard-pygmentsrb'
#     gem 'pygments.rb'
#
# then your markdown can include code fragments like:
# ``` ruby
#   puts 'Howdy!'
# ```
#
# Uses these settings:
#
# * Settings[:app_name]
# * Settings[:source_dirs]
# * Settings[:yard_output_dir]


begin
  require 'yard'
  #require 'yard-cucumber'
  #require 'yard-rspec'      # doesn't work
  #require 'yard-notes'       # doesn't work
  require File.expand_path('version.rb', File.dirname(__FILE__))

  desc 'Remove the generated documentation'
  task :clean do
    puts "removing yard documentation"
    FileUtils.rm_rf File.expand_path(Settings[:yard_output_dir], Rake.application.original_dir)
    FileUtils.rm_rf File.expand_path('.yardoc', Rake.application.original_dir)
  end

  begin
    require 'erb'
    desc 'Convert .md.erb documentation to .md'
    task :markdown_erb do
      Dir['**/*.md.erb'].each do |fn|
        output_file = File.expand_path(fn.gsub(/\.md\.erb$/, '.md'), File.dirname(__FILE__))
        puts "processing: #{fn} to #{output_file}"
        template = ERB.new IO.read(fn)
        File.open(output_file, 'w') {|f| f.puts template.result(binding)}
      end
    end
  rescue LoadError
    task :markdown_erb do
    end
  end

  YARD::Rake::YardocTask.new do |t|
    t.files = (Dir["{#{Settings[:source_dirs].join(',')}}/**/*.rb"] +
        Dir["{#{Settings[:test_dirs].join(',')}}/**/*_spec.rb"] +
        Dir["{#{Settings[:test_dirs].join(',')}}/**/*.feature"] +
        Dir["{#{Settings[:test_dirs].join(',')}}/**/support/**/*.rb"]).uniq

    t.options = ['--title', "#{Settings[:app_name]} #{Version.version_get}".strip,
                 '--output-dir', Settings[:yard_output_dir],
                 '--protected', '--private', '--embed-mixins',
                 '--markup', 'markdown',
                 '--readme', 'README.md']
    #puts "t.files => #{t.files.pretty_inspect}"
  end

  require 'digest/md5'
  task :yard_config do
    FileUtils.mkdir_p File.expand_path('~/.yard')
    config_file = File.expand_path("~/.yard/config")
    config = SymbolHash.new
    config = YAML.load IO.read(config_file) if File.exist? config_file
    config_sha1 = Digest::MD5.hexdigest(config.to_s)
    config[:'yard-cucumber'] ||= {"menus"=>["features", "tags", "steps", "step definitions", "specifications"],
                                  "language"=>{"step_definitions"=>["Given", "When", "Then", "And"]}}
    config[:'load_plugins'] ||= true
    config[:'ignored_plugins'] ||= []
    config[:'autoload_plugins'] ||= []
    config[:'safe_mode'] ||= false
    unless config_sha1 == Digest::MD5.hexdigest(config.to_s)
      File.open(config_file, 'w') {|f| f.puts YAML.dump(config)}
    end
  end

  task :yard => [:yard_config]

  desc 'Generate Documentation from .md.erb, .md, .rb'
  task :doc => [:markdown_erb, :yard]
rescue LoadError
  warn "yard or erb not available, yard documentation tasks not provided."
end
