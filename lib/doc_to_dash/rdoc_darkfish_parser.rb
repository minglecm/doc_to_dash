require 'json'

module DocToDash
  class RdocDarkfishParser
    def initialize(doc_directory)
      @doc_directory  = doc_directory
      @classes        = []
      @methods        = []

      fix_css_file

      load_search_json
      parse_through_json
    end

    def fix_css_file
      File.open(@doc_directory + '/rdoc.css', 'a') { |file| file.write('nav, footer { display: none !important; } #documentation { margin: 0 !important; } .method-source-code { display: block !important; }') }
    end

    def load_search_json
      search_index_js_path = @doc_directory + '/js/search_index.js'
      search_index_js_file = File.read(search_index_js_path)
      search_index_js_file.gsub!('var search_data = ', '')

      @search_json = JSON::parse(search_index_js_file)
      @search_json = @search_json["index"]["info"]
    end

    def parse_through_json
      return false unless @search_json

      blacklist   = %w{README_FOR_APP}

      @search_json.each do |item|
        next if blacklist.include?(item[0])

        if item[3] == ""
          @classes << [item[2], item[0]]
        elsif item[3] == "()"
          @methods << [item[2], "#{item[1]}##{item[0]}"]
        end
      end

      true
    end

    def classes
      @classes
    end
    alias :parse_classes :classes

    def methods
      @methods
    end
    alias :parse_methods :methods
  end
end