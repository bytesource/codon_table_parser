require 'parslet'
require 'parslet/convenience'
require 'pp'

text = File.read('data/codons.txt')

class CodonsParser < Parslet::Parser

  rule(:file)            {to_be_neglected.as(:discard) | content.as(:codons)} # ((dircard | content).newline).repeat(1)
  rule(:to_be_neglected) {(match('\n\s{2}\d').absent? >> any).repeat(1)}
  rule(:content)         {(match('\n\s{2}\d') >> any) >> repeat(1)}
  # rule(:content)         {long_name >> short_name.maybe >> id >> ncbieaa >> sncbieaa}
  # rule(:long_name)       {}
  # rule(:short_name)      {}
  # rule(:id)              {}
  # rule(:ncbieaa)         {}
  # rule(:sncbieaa)        {}

  # rule(:newline)         {lf >> cr.maybe}
  # rule(:lf)              {str("\n")}
  # rule(:cr)              {str("\r")}
  
  root(:file)
end

pp CodonsParser.new.parse_with_debug(text)

