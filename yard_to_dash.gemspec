# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'yard_to_dash/version'

Gem::Specification.new do |gem|
  gem.name          = "yard_to_dash"
  gem.version       = YardToDash::VERSION
  gem.authors       = ["Caleb Mingle"]
  gem.email         = ["me@caleb.io"]
  gem.description   = "Converts YARD documentation to a Dash Docset"
  gem.summary       = "Yard to Dash Docset Converter"
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "nokogiri"
  gem.add_dependency "sqlite3"
end
