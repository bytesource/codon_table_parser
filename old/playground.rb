require '../codontableparser'

table = CodonTableParser.new('../data/codons.txt')

puts "DEFINITIONS:"
puts table.definitions
puts "START CODONS"
puts table.starts
puts "STOP CODONS"
puts table.stops
puts "TABLES:"
puts table.tables
