require "yard_to_dash/version"
require 'sqlite3'
require 'fileutils'
require 'nokogiri'

module YardToDash
  class DocsetGenerator
    def initialize(options = {})
      @classes      = []
      @methods      = []

      @options = {
          :docset_name            => 'DefaultDocset',
          :docset_output_path     => 'doc/',      # This is where the actual package will be created.
          :docset_output_filename => lambda {@options[:docset_name] + '.docset' },
          :icon_path              => nil,                                                         # This is the docset icon that never changes, if you want a default icon just set this to nil.
          :doc_input_path         => nil,                                                         # This is the actual docs to copy over to the Docset.
          :doc_save_folder        => 'yard',                                                      # This is the directory name it will store under /Contents/Resources/Documents/{this}
          :verbose                => true
      }.merge(options)

      @docset_path  = File.expand_path(@options[:docset_output_path]) + '/' + @options[:docset_output_filename].call
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
      copy_yard_docs_to_docset

      create_database

      parse_methods
      parse_classes

      load_methods_into_database
      load_classes_into_database

      log "Docset created."

      @docset_path
    end

    private

    def log(message)
      puts "=> #{message}" if @options[:verbose]
    end

    def check_and_format_options
      if @options[:doc_input_path].nil?
        @error = "You must provide a path to your YARD docs. (:doc_input_path)"
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

      FileUtils.cp @options[:icon_path], @docset_path + '/' unless @options[:icon_path].nil?
      File.open(@docset_path + '/Contents/Info.plist', 'w+') { |file| file.write(default_plist.gsub('{DOCSET_NAME}', @options[:docset_name])) }
    end

    def copy_yard_docs_to_docset
      log "Copying YARD documentation to Docset."

      FileUtils.cp_r @options[:doc_input_path], @docset_path + '/Contents/Resources/Documents/'

      @doc_directory = @docset_path + '/Contents/Resources/Documents/' + @options[:doc_save_folder]
    end

    def create_database
      log "Creating Docset index database."

      @db = SQLite3::Database.new(@docset_path + '/Contents/Resources/docSet.dsidx')
      @db.execute('CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT)')
    end

    def parse_methods
      log "Parsing methods."

      classes_file = File.read(@doc_directory + '/class_list.html')
      classes_html = Nokogiri::HTML(classes_file)

      classes_html.xpath('//li').children.select{|c| c.name == "span"}.each do |method|
        a     = method.children.first
        title = a.children.first.to_s.gsub('#', '')
        href  = a["href"].to_s

        @classes << [href, title] unless title == "Top Level Namespace"
      end
    end

    def parse_classes
      log "Parsing classes."

      methods_file = File.read(@doc_directory + '/method_list.html')
      methods_html = Nokogiri::HTML(methods_file)

      methods_html.xpath('//li').children.select{|c| c.name == "span"}.each do |method|
        a     = method.children.first
        href  = a["href"].to_s
        name  = a["title"].to_s.gsub(/\((.+)\)/, '').strip! # Strip the (ClassName) and whitespace.

        @methods << [href, name]
      end
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
        </dict>
        </plist>
XML
    end
  end
end