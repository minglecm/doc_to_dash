
begin
  require 'doc_to_dash'

  require "doc_to_dash/parsers/rdoc_darkfish_parser" # Required because it defaults to this.

  desc 'Generate a docset for Dash from rdoc'
  task :rdoc_docset => [:rdoc] do
    DocToDash::DocsetGenerator.new(:docset_name => "#{Settings[:app_name]} Docset",
                                   :docset_output_path => Settings[:doc_dir],
                                   :doc_input_path => Settings[:rdoc_output_dir],
                                   :parser => DocToDash::RdocDarkfishParser
    ).run
  end

  desc 'Generate a docset for Dash from yard'
  task :yard_docset => [:doc] do
    DocToDash::DocsetGenerator.new(:docset_name => "#{Settings[:app_name]} Docset",
                                   :docset_output_path => Settings[:doc_dir],
                                   :doc_input_path => Settings[:yard_output_dir],
                                   :parser => DocToDash::YardParser
    ).run
  end
rescue LoadError
  warn "doc_to_dash not available, docset tasks not provided."
end
