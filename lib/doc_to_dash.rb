require "doc_to_dash/version"
require "doc_to_dash/cli"
require "doc_to_dash/parsers/yard_parser" # Required because it defaults to this.
require 'sqlite3'
require 'fileutils'
require 'nokogiri'

module DocToDash
  class DocsetGenerator
    def initialize(options = {})
      @classes      = []
      @methods      = []

      @options = {
          :docset_name            => 'DefaultDocset',
          :docset_output_path     => 'doc/',                                                                              # This is where the actual package will be created.
          :docset_output_filename => lambda {@options[:docset_name] + '.docset' },
          :icon_path              => File.expand_path(File.expand_path(File.dirname(__FILE__)) + '/../default_icon.png'), # This is the docset icon that never changes, if you want a default icon just set this to nil.
          :doc_input_path         => nil,                                                                                 # This is the actual docs to copy over to the Docset.
          :doc_save_folder        => 'docs',                                                                              # This is the directory name it will store under /Contents/Resources/Documents/{this}
          :verbose                => true,
          :parser                 => DocToDash::YardParser
      }.merge(options)

      @docset_path    = File.expand_path(@options[:docset_output_path]) + '/' + @options[:docset_output_filename].call
      @doc_directory  = @docset_path + '/Contents/Resources/Documents/' + @options[:doc_save_folder]
    end

    def run
      log "Beginning to generate Dash Docset."

      unless check_and_format_options
        log "Error: " + @error # There was an error of some sort..
        return false
      end


      clean_up_files
      create_structure
      copy_default_files
      copy_docs_to_docset

      create_database

      parser = @options[:parser].new(@doc_directory)

      @classes = parser.parse_classes
      @methods = parser.parse_methods

      if @methods && @classes
        load_methods_into_database
        load_classes_into_database

        log "Docset created."
        @docset_path
      else
        log "Docset could not be created. Parser returned no data."
        return false
      end

    rescue Errno::ENOENT
      log "Oops! Seems you've given us a wrong file path."
    end

    private

    def log(message)
      puts "=> #{message}" if @options[:verbose]
    end

    def check_and_format_options
      if @options[:doc_input_path].nil?
        @error = "You must provide a path to your docs. (:doc_input_path)"
        return false
      end

      if @options[:doc_save_folder].nil?
        @error = "You must provide a doc_path_name for us to save under. (:doc_save_folder)"
        return false
      end

      @options[:doc_input_path] = File.expand_path(@options[:doc_input_path])

      true
    end

    def clean_up_files
      log "Removing old Docset."
      FileUtils.rm_rf(@docset_path) if Dir.exist?(@docset_path)
    end

    def create_structure
      log "Creating new Docset structure."

      FileUtils.mkdir_p(@docset_path)
      FileUtils.mkdir_p(@docset_path + '/' + 'Contents/Resources/Documents/')
    end

    def copy_default_files
      log "Copy default Docset files over."

      unless @options[:icon_path].nil?
        FileUtils.cp @options[:icon_path], @docset_path + '/'
        filename = File.basename(@options[:icon_path])
        FileUtils.mv @docset_path + '/' + filename, @docset_path + '/icon.png' if filename != 'icon.png'
      end

      File.open(@docset_path + '/Contents/Info.plist', 'w+') { |file| file.write(default_plist.gsub('{DOCSET_NAME}', @options[:docset_name])) }
    end

    def copy_docs_to_docset
      log "Copying documentation to Docset."

      new_doc_path  = @docset_path + '/Contents/Resources/Documents/'
      FileUtils.cp_r @options[:doc_input_path], new_doc_path
      FileUtils.mv new_doc_path + File.basename(@options[:doc_input_path]), new_doc_path + @options[:doc_save_folder]
    end

    def create_database
      log "Creating Docset index database."

      @db = SQLite3::Database.new(@docset_path + '/Contents/Resources/docSet.dsidx')
      @db.execute('CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT)')
    end

    def load_methods_into_database
      log "Loading methods into database."
      insert_into_database @methods, 'clm'
    end

    def load_classes_into_database
      log "Loading classes into database."
      insert_into_database @classes, 'cl'
    end

    def insert_into_database(array, type)
      array.each { |item| @db.execute("insert into searchIndex (name, type, path) VALUES(?, ?, ?)", item.last, type, @options[:doc_save_folder] + '/' + item.first) }
    end

    def default_plist
      return <<XML
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleIdentifier</key>
          <string>{DOCSET_NAME}</string>
          <key>CFBundleName</key>
          <string>{DOCSET_NAME}</string>
          <key>DocSetPlatformFamily</key>
          <string>{DOCSET_NAME}</string>
          <key>isDashDocset</key>
          <true/>
          <key>dashIndexFilePath</key>
          <string>#{@options[:doc_save_folder]}/index.html</string>
        </dict>
        </plist>
XML
    end
  end
end