# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doc_to_dash/version'

Gem::Specification.new do |gem|
  gem.name          = "doc_to_dash"
  gem.version       = DocToDash::VERSION
  gem.authors       = ["Caleb Mingle"]
  gem.email         = ["me@caleb.io"]
  gem.description   = "Converts documentation to a Dash Docset"
  gem.summary       = "Documentation to Dash Docset Converter"
  gem.homepage      = "https://rubygems.org/gems/doc_to_dash"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri"
  gem.add_dependency "sqlite3"

  gem.executables   << 'doc_to_dash'
end