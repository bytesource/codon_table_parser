require 'parslet'
require 'parslet/convenience'
require 'pp'

text = File.read('data/codons.txt')
pp text

class CodonsParser < Parslet::Parser

  rule(:file)            {(line >> newline).repeat(1)}          
  rule(:line)            {(content.as(:codon) | no_value.as(:comment)).repeat}
  rule(:content)         {(match('^\s{2}\d') >> any) >> repeat(1)}
  rule(:no_value)        {(match('^\s{2}\d').absent? >> any).repeat(1)}
  # rule(:content)         {long_name >> short_name.maybe >> id >> ncbieaa >> sncbieaa}
  # rule(:long_name)       {}
  # rule(:short_name)      {}
  # rule(:id)              {}
  # rule(:ncbieaa)         {}
  # rule(:sncbieaa)        {}

  rule(:newline)         {lf >> cr.maybe}
  rule(:lf)              {str("\n")}
  rule(:cr)              {str("\r")}
  
  root(:file)
end

pp CodonsParser.new.parse_with_debug(text)

