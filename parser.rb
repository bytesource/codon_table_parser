require 'parslet'
require 'parslet/convenience'
require 'pp'

text = File.read('data/codons.txt')
# pp text

class CodonsParser < Parslet::Parser

  rule(:file)            {(line >> newline.maybe).repeat}          
  rule(:line)            {content.as(:value) | no_value.as(:comment)}
  rule(:content)         {match('\s{2}\d+\s') >> textdata.repeat}
  rule(:no_value)        {match('\s{2}\d+\s').absent? >> textdata.repeat(1)}
  rule(:textdata)        {((lf | cr).absent? >> any).repeat(1)}
  # rule(:content)         {long_name >> short_name.maybe >> id >> ncbieaa >> sncbieaa}
  # rule(:long_name)       {}
  # rule(:short_name)      {}
  # rule(:id)              {}
  # rule(:ncbieaa)         {}
  # rule(:sncbieaa)        {}

  rule(:newline)         {lf.repeat(1) >> cr.maybe}
  rule(:lf)              {str("\n")}
  rule(:cr)              {str("\r")}
  
  root(:file)
end

pp CodonsParser.new.parse_with_debug(text)
# EVERY line is parsed as a comment:

# {:comment=>
#    "--**************************************************************************"@0},
#  {:comment=>"--  This is the NCBI genetic code table"@77},
#  {:comment=>
#    "--  Initial base data set from Andrzej Elzanowski while at PIR International"@117},
# ...
# ...
# {:comment=>"  name \"Thraustochytrium Mitochondrial\" ,"@10199},
#  {:comment=>"  id 23 ,"@10241},
#  {:comment=>
#    "  ncbieaa  \"FF*LSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG\","@10251},
#  {:comment=>
#    "  sncbieaa \"--------------------------------M--M---------------M------------\""@10330},
# ...
#  {:comment=>"}"@10642}]


