require '../codontableparser'

# table = CodonTableParser.new('../data/codons.txt')
table = CodonTableParser.new

require 'pp'

puts "DEFINITIONS:"
pp table.definitions
puts "START CODONS"
pp table.starts
puts "STOP CODONS"
pp table.stops
puts "TABLES:"
# puts table.tables
puts "BUNDLE"
# pp table.bundle
puts "CUSTOM START CODONS"


# ---------------------------------------
text  = File.read('data/codons.txt')

def split_text s
  s.split(/[{}]/).drop(1).map do |m|
    m.split(/,/)
  end
end

def filter_text s
  s.select do |m|
    m[0] =~ /name/
  end
end

def create_hash arr
  keys1 = [:l_name, :s_name, :id, :ncbieaa, :sncbieaa]
  keys2 = [:l_name, :id, :ncbieaa, :sncbieaa]
  keys = has_short_name?(arr) ? keys1 : keys2
  hash = keys.zip(arr).flatten
  Hash[*hash]
end

def has_short_name? arr
  arr.size == 5
end

def parse s
  text = (filter_text (split_text s))
  text.map do |x|
    create_hash x
  end
end

pp parse text
