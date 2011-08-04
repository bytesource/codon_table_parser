# Parses the NCBI genetic code table, generating separate hash maps of each species' name, start & stop codons and codon table.  
#
# to return definitions, start  & stop codons as well as codon tables that can be used 
class CodonTableParser

  attr_reader :address

  @default_address = 'ftp://ftp.ncbi.nih.gov/entrez/misc/data/gc.prt'

  class << self
    attr_accessor :default_address
  end

  def initialize(path = '')
    @address     = CodonTableParser.default_address
    data         = content(path)
    @codons      = triplets(data)
    @parsed_data = parse(data)
  end

  def content path
    if path.empty?
      require 'open-uri'
      f = open(@address)
    else
      f = File.new(path)
    end

    first_line = f.readline
    raise Exception, "This is not the NCBI genetic code table" unless first_line =~ /--\*+/
    f.read.each_line do |line|
      next if line.match(/-- /)
      line
    end
  end

  def triplets data
    base1, base2, base3 = bases data
    arr = []

    base1.each_with_index do |base, i|
      arr << (base + base2[i] + base3[i]).downcase
    end
    arr
  end

  def parse data 
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


  def definitions options = {}
    Hash[@parsed_data.map do |species|
      id        = species[:id]
      name      = species[:long_name]
      new_names = options[:names]
      if new_names
        name = new_names[id] if new_names[id]
      end
      custom_range(options[:range], id) {[id, name]}
    end]
  end

  def starts options = {}
    Hash[@parsed_data.map do |species| 
      codons = []
      species[:sncbieaa].split(//).each_with_index do |pos, i|
        if pos == 'M'
          codons << @codons[i]
        end
      end
      id  = species[:id]
      # Options can either be passed as :starts => {1 => {:add => ...}} or 1 => {:add => ...}
      selection = options[:starts] || options
      codons = custom_codons(selection[id], codons)
      custom_range(options[:range], id) {[id, codons]}
    end]
  end


  def stops options = {}
    Hash[@parsed_data.map do |species|
      codons = []
      species[:ncbieaa].split(//).each_with_index do |pos, i|
        if pos == '*'
          codons << @codons[i]
        end
      end

      id = species[:id]
      # Options can either be passed as :stops => {1 => {:add => ...}} or 1 => {:add => ...}
      selection = options[:stops] || options
      codons = custom_codons(selection[id], codons)
      custom_range(options[:range], id) {[id, codons]}
    end]
  end

  def tables options = {}
    Hash[@parsed_data.map do |species|
      id = species[:id]
      codon_table = table(@codons, species[:ncbieaa])
      custom_range(options[:range], id) {[id, codon_table]}
    end]
  end

  def bundle options = {}
    {:definitions => definitions(options),
     :starts       => starts(options),
     :stops        => stops(options),
     :tables       => tables(options)}
  end


  def bases data
    del   = /[^\n]*\n\s+/.source
    base1 = /-- Base1\s+([A-Z]+)#{del}/.source
    base2 = /-- Base2\s+([A-Z]+)#{del}/.source
    base3 = /-- Base3\s+([A-Z]+)/.source
    data.scan(/#{base1}#{base2}#{base3}/m).first.map do |base|
      base.split(//)
    end
  end

  def prepare_range range
    require 'set'
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


  def custom_codons options, codons
    opt = options
    if opt 
      codons = codons | opt[:add] if opt[:add]
      codons = codons.delete_if {|codon| opt[:remove].include?(codon)} if opt[:remove]
    end
    codons
  end

  def table triplets, ncbieaa
    ncbieaa = ncbieaa.split(//)

    hash = {}
    triplets.each_with_index do |codon, i|
      hash[codon] = ncbieaa[i]
    end
    hash
  end

  private :content, :bases, :prepare_range, :custom_range, :custom_codons, :table
end

