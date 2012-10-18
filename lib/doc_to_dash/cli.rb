require_relative 'trollop'

module DocToDash
  class CLI
    def self.run
      self.new.run
    end

    def initialize
      @opts = Trollop::options do
        banner DocToDash::CLI.banner_data
        opt :icon,    "Docset icon which will display in Dash.",            :type => :string
        opt :name,    "Docset name which will dispaly in Dash.",            :type => :string
        opt :output,  "Docset Output Path where the docset will be saved.", :type => :string
        opt :parser,  "Docset parser to use.",                              :type => :string
      end
    end

    def run
      if ARGV.count == 0
        puts "Error.  Please run doc_to_dash again with the --help switch.  Missing <docset_path>."
        return false
      end

      docset_options = {}
      docset_options[:doc_input_path]     = ARGV.first
      docset_options[:icon_path]          = @opts[:icon]                        unless @opts[:icon].nil?
      docset_options[:docset_name]        = @opts[:name]                        unless @opts[:name].nil?
      docset_options[:docset_output_path] = @opts[:output]                      unless @opts[:output].nil?
      docset_options[:parser]             = DocToDash.const_get(@opts[:parser]) unless @opts[:parser].nil?

      DocToDash::DocsetGenerator.new(docset_options).run
    end

    def self.banner_data
      <<-EOS
DocToDash converts RDoc and YARD documentation files to Dash format.

Usage:
        doc_to_dash [options] <docset_path>

where [options] are:
      EOS
    end
  end
end