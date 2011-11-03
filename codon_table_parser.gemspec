require File.expand_path("lib/codon_table_parser/version")

Gem::Specification.new do |s|
  s.name = "codon_table_parser"
  s.version = CodonTableParser::VERSION
  s.authors = ["Stefan Rohlfing"]
  s.date = Time.now.strftime('%Y-%m-%d')
  s.description = <<-DESCRIPTION
   Parses the NCBI genetic code table, generating hash maps of each species' name, start codons, stop codons and codon table. The output of CodonTableParser can be customized easily and used to update the respective constants of BioRuby's CodonTable class whenever the original data has changed.
   DESCRIPTION
  s.summary = "Parses the NCBI genetic code table, generating hash maps of each species' name, start codons, stop codons and codon table."
  s.email = 'stefan.rohlfing@gmail.com'
  s.homepage = 'http://github.com/bytesource/codon_table_parser'
  s.has_rdoc = false
  s.required_ruby_version = '>= 1.9.1'
  s.rubyforge_project = 'codon_table_parser'
  s.add_development_dependency 'rspec'
  s.files = Dir["{lib, spec}/**/*.rb", "*.md", 'Rakefile', 'LICENSE']
end
