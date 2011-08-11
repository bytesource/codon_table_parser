require 'parslet'
require 'parslet/convenience'
require 'pp'

text  = File.read('data/codons.txt')




class CodonsParser < Parslet::Parser

  rule(:file)    {(data | no_data.as(:no_data)).repeat(1)}

  rule(:data)    {l_name >> s_name.maybe >> id >> ncbieaa >> sncbieaa}
  rule(:no_data) {(data.absent? >> any).repeat(1)}

  rule(:l_name)   {(str('  name ') | str('    name ')) >> d_quote >> ((text | lf).repeat).as(:l_name) >> d_quote >> eol}
  rule(:s_name)   {str('name ') >> d_quote >> ((text | integer).repeat).as(:s_name) >> d_quote >> eol}
  rule(:id)       {str('id ') >> integer.as(:id)}
  rule(:ncbieaa)  {str('ncbieaa  ') >> d_quote >> text.as(:ncbieaa) >> d_quote >> eol}
  rule(:sncbieaa) {str('sncbieaa ') >> d_quote >> text.as(:sncbieaa) >> d_quote}

  rule(:eol)      {space.maybe >> str(",\n  ")}
  rule(:integer)  {match('[0-9]').repeat(1)}
  # # 'match': All regular expressions can be used, as long as they match only a SINGLE character at a time. 
  rule(:text)     {(match('[A-Z]') | match('[a-z]') | space | str(';') | str('*') | str('-')).repeat(1)}
  rule(:d_quote)  {str('"')}
  rule(:space)    {str("\s").repeat(1)}
  rule(:lf)       {str("\n")}
  rule(:cr)       {str("\r")}
  
  root(:file)
end

# pp CodonsParser.new.parse_with_debug(text)


class TestParser < Parslet::Parser

  rule(:l_name)   {(str('  name ') | str('    name ')) >> d_quote >> ((text | lf).repeat).as(:l_name) >> d_quote >> eol}
  rule(:eol)      {space.maybe >> str(",\n  ")}
  rule(:integer)  {match('[0-9]').repeat(1)}
  # # 'match': All regular expressions can be used, as long as they match only a SINGLE character at a time. 
  rule(:text)     {(match('[A-Z]') | match('[a-z]') | space | str(';') | str('*') | str('-')).repeat(1)}
  rule(:d_quote)  {str('"')}
  rule(:space)    {str("\s").repeat(1)}
  rule(:lf)       {str("\n")}
  rule(:cr)       {str("\r")}
  root(:l_name)
end


snippet = <<DNA
  name "Echinoderm Mitochondrial; Flatworm Mitochondrial" ,\n  
DNA

pp TestParser.new.parse_with_debug(snippet)


