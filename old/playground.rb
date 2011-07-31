require '../codontableparser'

table = CodonTableParser.new('../data/codons.txt')

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
