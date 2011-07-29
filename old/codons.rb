# NOTE: Use httparty to get the data!
# Example use: https://github.com/jnunemaker/httparty/tree/master/examples
# Data source: ftp://ftp.ncbi.nih.gov/entrez/misc/data/gc.prt
require 'httparty'

def data path
  f = File.new(path)
  first_line = f.readline
  raise Exception, "This is not the NCBI genetic code table" unless first_line =~ /--\*+/
  f.read.each_line do |line|
    next if line.match(/-- /)
    line
  end
end


def convert data 
  del       = /[^\n]*\n\s+/.source          # .+ does not work as the regex is greedy.
  l_name    = /name "([^"]+)#{del}/.source
  s_name    = /(|name "[^"]+#{del})/.source # Either nothing 'line does not exists' or the short name.
  id        = /id (\d+)#{del}/.source
  ncbieaa   = /ncbieaa  "([^"]+)#{del}/.source
  sncbieaa  = /sncbieaa "([^"]+)/.source

  result = data.scan(/#{l_name}#{s_name}#{id}#{ncbieaa}#{sncbieaa}/m).
                inject([]) do |res, (l_name, s_name, id, ncbieaa, sncbieaa)|

    short = s_name.match(/[A-Z]{3}\d/)[0] unless s_name.empty?
    res << {:id         => id.to_i, 
            :long_name  => l_name.gsub(/\n/,''),
            :short_name => short,
            :ncbieaa    => ncbieaa,
            :sncbieaa   => sncbieaa}
  end

  result
end

def bases data
  del   = /[^\n]*\n\s+/.source
  base1 = /-- Base1\s+([A-Z]+)#{del}/.source
  base2 = /-- Base2\s+([A-Z]+)#{del}/.source
  base3 = /-- Base3\s+([A-Z]+)/.source
  data.scan(/#{base1}#{base2}#{base3}/m).first.map do |base|
    base.scan(/./)
  end
end


def definitions converted, options = {}
  Hash[converted.map do |species|
    id        = species[:id]
    name      = species[:long_name]
    new_names = options[:names]
    if new_names
      name = new_names[id] if new_names[id]
    end
    custom_range(options[:range], id) {[id, name]}
  end]
end


def codons
  base1, base2, base3 = bases data '../data/codons.txt'

  arr = []

  base1.each_with_index do |base, i|
    arr << (base + base2[i] + base3[i]).downcase
  end

  arr
end


def start_codons converted, triplets, options = {}
  Hash[converted.map do |species| 
    codons = []
    species[:sncbieaa].scan(/./).each_with_index do |pos, i|
      if pos == 'M'
        codons << triplets[i]
      end
    end

    id  = species[:id]
    # Options can either be passes as :starts => {1 => {:add => ...}} or 1 => {:add => ...}
    selection = options[:starts] || options
    codons = custom_codons(selection[id], codons)
    custom_range(options[:range], id) {[id, codons]}
  end]
end

def custom_codons options, codons
  opt = options
  if opt 
    codons = codons | opt[:add] if opt[:add]
    codons = codons.delete_if {|codon| opt[:remove].include?(codon)} if opt[:remove]
  end
  codons
end

def stop_codons converted, triplets, options = {}
  Hash[converted.map do |species|
    codons = []
    species[:ncbieaa].scan(/./).each_with_index do |pos, i|
      if pos == '*'
        codons << triplets[i]
      end
    end

    id = species[:id]
    selection = options[:stops] || options
    codons = custom_codons(selection[id], codons)
    custom_range(options[:range], id) {[id, codons]}
  end]
end


def table triplets, ncbieaa
  ncbieaa = ncbieaa.scan(/./)

  hash = {}
  triplets.each_with_index do |codon, i|
    hash[codon] = ncbieaa[i]
  end
  hash
end

def prepare_range range
  range.map do |val|
    val.is_a?(Range) ? val.to_a : val
  end.flatten.to_set.sort
end

def custom_range options, id, &block
  range = prepare_range options if options
  if range
    block.call if range.include?(id)
  else
    block.call
  end
end


def codon_tables converted, triplets, options = {}
  Hash[converted.map do |species|
    id = species[:id]
    codon_table = table triplets, species[:ncbieaa]
    custom_range(options[:range], id) {[id, codon_table]}
  end]
end

# Rename to 'bundle'
def print converted, triplets, options = {}
  [definitions(converted, options),
   start_options = 
   start_codons(converted, triplets, options),
   stop_codons(converted, triplets, options),
   codon_tables(converted, triplets, options)]
end

# add helper function 'table' to create a single table
# Hash[:a, 1, :b, 2]
# => {:a=>1, :b=>2} 




# CodonTable.print :all
# CodonTable.print :starts, :stops 
