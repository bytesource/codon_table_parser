require 'parslet'
require 'parslet/convenience'
require 'pp'

text  = File.read('data/codons.txt')




class CodonsParser < Parslet::Parser

  rule(:file)    {comment | block}
  rule(:comment)  {(open.absent? >> any).repeat(1) >> open}
  rule(:block)    {(close.absent? >> any).repeat(1) >> close}

  rule(:open)    {str('{')}
  rule(:close)   {str('}')}

  # rule(:file)            {(block.as(:block) >> comma.maybe).repeat}
  # rule(:block)           {long_name | id | text}
  # rule(:long_name)       {str("\n {\n  name ") >> str('"') >> ((str('"').absent? >> text).repeat).as(:long_name) >> str('" ')}
  # rule(:id)              {str("\n  id ") >> (match('\d').repeat).as(:id) >> text}
  # 
  # rule(:text)            {(comma.absent? >> any).repeat(1)}
  # rule(:comma)           {str(',')}

  # rule(:file)            {(line >> newline.maybe).repeat}   
  # # As Parslet tries to match :content first, it will only match :no_value if it didn't match :content.
  # rule(:line)            {content | no_value.as(:comment)} 
  # rule(:content)         {long_name | id}
  # rule(:no_value)        {textdata.repeat(1)}
  # rule(:textdata)        {((lf | cr).absent? >> any).repeat(1)}
  # rule(:long_name)       {str('  name "') >> ((any | lf).repeat).as(:long_name) >> str('"') >> textdata.repeat}
  # # rule(:ncbieaa)         {}
  # # 'match': All regular expressions can be used, as long as they match only a SINGLE character at a time. 
  # rule(:id)              {str('  id ') >> (match('\d').repeat).as(:id) >> textdata.repeat}
  # # rule(:content)         {long_name >> short_name.maybe >> id >> ncbieaa >> sncbieaa}
  # # rule(:short_name)      {}
  # # rule(:id)              {}
  # # rule(:sncbieaa)        {}
  rule(:newline)         {lf.repeat(1) >> cr.maybe}
  rule(:lf)              {str("\n")}
  rule(:cr)              {str("\r")}
  
  root(:file)
end

# pp CodonsParser.new.parse_with_debug(text)
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


