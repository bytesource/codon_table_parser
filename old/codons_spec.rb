require File.expand_path('codons')

describe "First Conversion" do

  before(:each) do
    @data  = data '../data/codons.txt'
  end

  it "should throw an exception if a file with the wrong content is passed" do
    wrong_file = '../data/dummy.txt'

    lambda do
      data(wrong_file)
    end.should raise_error(Exception, "This is not the NCBI genetic code table")
  end


  it "'convert': should convert the data correctly" do

    converted = convert(@data)
    converted.count.should == 17
    converted.inject([]) do |res, species|
      res << species[:id]
    end.should == [1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16, 21, 22, 23]



    entry1 = converted[0]
    entry1.should == {:id=>1 , :long_name=>"Standard", :short_name=>"SGC0", 
                      :ncbieaa=>"FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", 
                      :sncbieaa=>"---M---------------M---------------M----------------------------"}

    entry2 = converted[3]
    entry2[:long_name].should  == "Mold Mitochondrial; Protozoan Mitochondrial; Coelenterate Mitochondrial; Mycoplasma; Spiroplasma"
    entry2[:short_name].should == "SGC3"

    entry3 = converted[16]
    entry3[:long_name].should  == "Thraustochytrium Mitochondrial"
    entry3[:short_name].should == nil
  end

  it "'bases': should return an array of base1, base2, and base3" do
    arr = bases @data
    arr.size.should == 3
    arr[0].join.should   == "TTTTTTTTTTTTTTTTCCCCCCCCCCCCCCCCAAAAAAAAAAAAAAAAGGGGGGGGGGGGGGGG" 
    arr[1].join.should   == "TTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGGTTTTCCCCAAAAGGGG"
    arr[2].join.should   == "TCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAGTCAG"
  end

  describe "Second Conversion" do

    before(:each) do
      @converted = convert(@data)
    end

    it "'definitions': should match ids and long names correctly" do

      def_hash = definitions @converted

      def_hash.count.should == 17
      def_hash.should ==
        {1=>"Standard", # name change in BioRuby's CodonTable class
         2=>"Vertebrate Mitochondrial",
         3=>"Yeast Mitochondrial", 
         4=>"Mold Mitochondrial; Protozoan Mitochondrial; Coelenterate Mitochondrial; Mycoplasma; Spiroplasma", #changed 
         5=>"Invertebrate Mitochondrial", 
         6=>"Ciliate Nuclear; Dasycladacean Nuclear; Hexamita Nuclear", # changed 
         9=>"Echinoderm Mitochondrial; Flatworm Mitochondrial", # changed 
         10=>"Euplotid Nuclear", 
         11=>"Bacterial and Plant Plastid", #changed 
         12=>"Alternative Yeast Nuclear", 
         13=>"Ascidian Mitochondrial", 
         14=>"Alternative Flatworm Mitochondrial", #changed 
         15=>"Blepharisma Macronuclear", 
         16=>"Chlorophycean Mitochondrial", 
         21=>"Trematode Mitochondrial", 
         22=>"Scenedesmus obliquus Mitochondrial", 
         23=>"Thraustochytrium Mitochondrial"}

      
    end

    it "'definitions': should only return the names for the ids specified with the 'range' option" do
      def_hash = definitions @converted, :range => [(1..3), 5]

      def_hash.should == 
        {1=>"Standard",
         2=>"Vertebrate Mitochondrial",
         3=>"Yeast Mitochondrial", 
         5=>"Invertebrate Mitochondrial"}

       

    end

    it "'definitions': should return the names given in the 'names' option" do
      def_hash = definitions @converted, :names => {1 => "hello", 3 => "world"}

      def_hash.size.should == 17
      def_hash[1].should == "hello"
      def_hash[3].should == "world"

      def_hash2 = definitions @converted, :names => {1  => "Standard (Eukaryote)",
                                                     4  => "Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma",
                                                     # Originial: "Yeast Mitochondrial"
                                                     3  => "Yeast Mitochondorial",
                                                     6  => "Ciliate Macronuclear and Dasycladacean",
                                                     9  => "Echinoderm Mitochondrial",
                                                     11 => "Bacteria",
                                                     14 => "Flatworm Mitochondrial",
                                                     # Original: Scenedesmus obliquus Mitochondrial
                                                     22	=> "Scenedesmus obliquus mitochondrial"}
      # Output from BioRuby's CodonTable:
      def_hash2.should == 
        {1      => "Standard (Eukaryote)",
         2	=> "Vertebrate Mitochondrial",
         3	=> "Yeast Mitochondorial",
         4	=> "Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma",
         5	=> "Invertebrate Mitochondrial",
         6	=> "Ciliate Macronuclear and Dasycladacean",
         9	=> "Echinoderm Mitochondrial",
         10	=> "Euplotid Nuclear",
         11	=> "Bacteria",
         12	=> "Alternative Yeast Nuclear",
         13	=> "Ascidian Mitochondrial",
         14	=> "Flatworm Mitochondrial",
         15	=> "Blepharisma Macronuclear",
         16	=> "Chlorophycean Mitochondrial",
         21	=> "Trematode Mitochondrial",
         22	=> "Scenedesmus obliquus mitochondrial",
         23	=> "Thraustochytrium Mitochondrial"}

    end

    it "'codons': should return the correct codons" do

      codons.each do |codon|
        codon.should =~ /[atcg]{3}/
      end.size.should == 64
    end 

    it "'start_codons': should return all start codons per entry as given in the original data" do
      @codons = codons
      @scs    = start_codons @converted, @codons

      @scs.size.should == 17
      @scs.keys.should == [1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16, 21, 22, 23]
      @scs.should      == 
        {
        1	=> ["ttg", "ctg", "atg"],   # need to add gtg		
        2	=> %w(att atc ata atg gtg),
        3	=> %w(ata atg),
        4	=> %w(tta ttg ctg att atc ata atg gtg),
        5	=> %w(ttg att atc ata atg gtg),
        6	=> %w(atg),
        9	=> %w(atg gtg),
        10	=> %w(atg),
        11	=> %w(ttg ctg att atc ata atg gtg),
        12	=> %w(ctg atg),
        13	=> ["ttg", "ata", "atg", "gtg"], # need to remove ttg, ata, gtg
        14	=> %w(atg),
        15	=> %w(atg),
        16	=> %w(atg),
        21	=> %w(atg gtg),
        22	=> %w(atg),
        23	=> %w(att atg gtg),
      }
    end

    it "'start_codons': should add or remove codons as specified in the options" do
      @codons = codons
      @scs1   = start_codons @converted, @codons, 1  => {:add    => ['gtg']}, 
                                                  13 => {:remove => ['ttg', 'ata', 'gtg']} 

      @scs1[1].should  == %w(ttg ctg atg gtg)
      @scs1[13].should == %w(atg)

      @scs2   = start_codons @converted, @codons, 1  => {:add  => ['gtg'], :remove => ['ttg', 'zzz']}
      @scs2[1].should  == %w(ctg atg gtg)

    end

    it "'start_codons': should only return the start codons for the ids specified in the 'range' option" do
      @codons = codons
      @starts  = start_codons @converted, @codons, :range => [(1..3), 3, 6, (21..23)]

      @starts.keys.should == [1, 2, 3, 6, 21, 22, 23]
    end

    it "'stop_codons': should return all stop codons per entry as given in the original data" do
      @codons = codons
      @stops  = stop_codons @converted, @codons

      @stops.size.should == 17
      @stops.keys.should == [1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16, 21, 22, 23]
      @stops.should      ==
        {
        1	=> %w(taa tag tga),
        2	=> %w(taa tag aga agg),
        3	=> %w(taa tag),
        4	=> %w(taa tag),
        5	=> %w(taa tag),
        6	=> %w(tga),
        9	=> %w(taa tag),
        10	=> %w(taa tag),
        11	=> %w(taa tag tga),
        12	=> %w(taa tag tga),
        13	=> %w(taa tag),
        14	=> %w(tag),
        15	=> %w(taa tga),
        16	=> %w(taa tga),
        21	=> %w(taa tag),
        22	=> %w(tca taa tga),
        23	=> %w(tta taa tag tga),
      }
    end

    it "'stop_codons': should add or remove codons as specified in the options" do
      @codons = codons
      @scs1   = stop_codons @converted, @codons, 1  => {:add    => ['gtg']}, 
                                                 13 => {:remove => ['taa', 'tag', 'zzz'], :add => ['gcc']} 

      @scs1[1].should  == %w(taa tag tga gtg)
      @scs1[13].should == %w(gcc)

      @scs2   = stop_codons @converted, @codons, 1  => {:add  => ['gtg'], :remove => ['taa', 'zzz']}
      @scs2[1].should  == %w(tag tga gtg)

    end

    it "'stop_codons': should only return the stop_codons for the ids specified in the options" do
      @codons = codons
      @stops  = stop_codons @converted, @codons, :range => [(1..3), 3, 6, (21..23)]

      @stops.keys.should == [1, 2, 3, 6, 21, 22, 23]
    end

    it "'tables': should return a hash mapping each codon to the correct amino acid" do
      @codons  = codons
      @ncbieaa = @converted[0][:ncbieaa]

      @table = table @codons, @ncbieaa
      @table.should ==

        # codon table 1
        {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      }
    end

    it "'codon_tables': should return the correct codon to aa table for each species" do
      @codons = codons
      @tables = codon_tables @converted, @codons

      @tables.size.should == 17

      @tables.should ==
        {

        # codon table 1
        1 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 2
      2 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => '*',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => '*',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },


      # codon table 3
      3 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'T', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'T', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'T', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'T', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 4
      4 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 5
      5 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'S',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 6
      6 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => 'Q', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => 'Q', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 9
      9 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 10
      10 => {

        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'C',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 11
      11 => {
        'ttt' => 'F', 'tct' => 'S', 'tat'	=> 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac'	=> 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa'	=> '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag'	=> '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat'	=> 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac'	=> 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa'	=> 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag'	=> 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat'	=> 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac'	=> 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa'	=> 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag'	=> 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat'	=> 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac'	=> 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa'	=> 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag'	=> 'E', 'ggg' => 'G',
      },

      # codon table 12
      12 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'S', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 13
      13 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'G',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'G',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 14
      14 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => 'Y', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 15
      15 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => 'Q', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 16
      16 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => 'L', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 21
      21 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 22
      22 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => '*', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => 'L', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 23
      23 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => '*', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      }
    end

    it "'prepare_range': should return a sorted set of values" do
      @range = prepare_range [(1..3), 5, (5..9)]
      @range.should == [1, 2, 3, 5, 6, 7, 8, 9]
    end

    it "'codon_tables' should only return the tables for the ids specified in the options" do
      @codons = codons
      @tables = codon_tables @converted, @codons, :range => [(1..3), 5]

      @tables.size.should == 4
    end

    it "'print': should print all tables, definitions, start, and stop codons" do
      @codons = codons

      @all = print @converted, @codons

      @all.size.should == 4
      @all[0].size.should == 17
      @all[1].size.should == 17
      @all[2].size.should == 17
      @all[3].size.should == 17
    end

    it "'print': should only output the ids of each hash as specified in the 'range' option" do
      @codons = codons

      @all = print @converted, @codons, :range => [(1..3), 5]
      @range = [1, 2, 3, 5]

      @all.size.should == 4
      @all.each do |hash|
        hash.keys.should == @range
      end
    end

    it "'print': should return the definitions, codon tables, start and stop codons 
        exactly as given in BioRuby's CodonTable (as of July 29th, 2011)" do

      @codons = codons
      @all    = print @converted, @codons,  :names => {1  => "Standard (Eukaryote)",
                                                       4  => "Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma",
                                                       3  => "Yeast Mitochondorial",
                                                       6  => "Ciliate Macronuclear and Dasycladacean",
                                                       9  => "Echinoderm Mitochondrial",
                                                       11 => "Bacteria",
                                                       14 => "Flatworm Mitochondrial",
                                                       22 => "Scenedesmus obliquus mitochondrial"},
                                            :starts => {1  => {:add    => ['gtg']}, 
                                                        13 => {:remove => ['ttg', 'ata', 'gtg']}}
      # definitions
      @all[0].should == {
        1	=> "Standard (Eukaryote)",
        2	=> "Vertebrate Mitochondrial",
        3	=> "Yeast Mitochondorial",
        4	=> "Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma",
        5	=> "Invertebrate Mitochondrial",
        6	=> "Ciliate Macronuclear and Dasycladacean",
        9	=> "Echinoderm Mitochondrial",
        10	=> "Euplotid Nuclear",
        11	=> "Bacteria",
        12	=> "Alternative Yeast Nuclear",
        13	=> "Ascidian Mitochondrial",
        14	=> "Flatworm Mitochondrial",
        15	=> "Blepharisma Macronuclear",
        16	=> "Chlorophycean Mitochondrial",
        21	=> "Trematode Mitochondrial",
        22	=> "Scenedesmus obliquus mitochondrial",
        23	=> "Thraustochytrium Mitochondrial",
      }
      # start codons
      @all[1].should ==
        {
        1	=> %w(ttg ctg atg gtg),		# gtg added (cf. NCBI #SG1 document)
        2	=> %w(att atc ata atg gtg),
        3	=> %w(ata atg),
        4	=> %w(tta ttg ctg att atc ata atg gtg),
        5	=> %w(ttg att atc ata atg gtg),
        6	=> %w(atg),
        9	=> %w(atg gtg),
        10	=> %w(atg),
        11	=> %w(ttg ctg att atc ata atg gtg),
        12	=> %w(ctg atg),
        13	=> %w(atg),
        14	=> %w(atg),
        15	=> %w(atg),
        16	=> %w(atg),
        21	=> %w(atg gtg),
        22	=> %w(atg),
        23	=> %w(att atg gtg),
      }
      # stop codons
      @all[2].should ==
        {
        1	=> %w(taa tag tga),
        2	=> %w(taa tag aga agg),
        3	=> %w(taa tag),
        4	=> %w(taa tag),
        5	=> %w(taa tag),
        6	=> %w(tga),
        9	=> %w(taa tag),
        10	=> %w(taa tag),
        11	=> %w(taa tag tga),
        12	=> %w(taa tag tga),
        13	=> %w(taa tag),
        14	=> %w(tag),
        15	=> %w(taa tga),
        16	=> %w(taa tga),
        21	=> %w(taa tag),
        22	=> %w(tca taa tga),
        23	=> %w(tta taa tag tga),
      }

      # codon tables
      @all[3].should ==
        {

        # codon table 1
        1 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 2
      2 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => '*',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => '*',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },


      # codon table 3
      3 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'T', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'T', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'T', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'T', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 4
      4 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 5
      5 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'S',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 6
      6 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => 'Q', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => 'Q', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 9
      9 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 10
      10 => {

        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'C',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 11
      11 => {
        'ttt' => 'F', 'tct' => 'S', 'tat'	=> 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac'	=> 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa'	=> '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag'	=> '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat'	=> 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac'	=> 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa'	=> 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag'	=> 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat'	=> 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac'	=> 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa'	=> 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag'	=> 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat'	=> 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac'	=> 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa'	=> 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag'	=> 'E', 'ggg' => 'G',
      },

      # codon table 12
      12 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'S', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 13
      13 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'G',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'G',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 14
      14 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => 'Y', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 15
      15 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => 'Q', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 16
      16 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => 'L', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 21
      21 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => 'W',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'M', 'aca' => 'T', 'aaa' => 'N', 'aga' => 'S',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'S',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 22
      22 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => '*', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => 'L', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      # codon table 23
      23 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => '*', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      },

      }

        end

    it "'print': should handle every possible option" do
      @codons = codons
      @all    = print @converted, @codons,  :range  => [1],
                                            :names  => {1  => "hello"}, 
                                            :starts => {1  => {:add => ["zzz"], :remove => ["ttg"]}}, 
                                            :stops  => {1  => {:add => ["zzz"], :remove => ["taa"]}} 

      @all[0].should == {1 => "hello"}
      @all[1][1].sort.should == %w(zzz ctg atg).sort
      @all[2][1].sort.should == %w(zzz tag tga).sort
      @all[3].should == {1 => {
        'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
        'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
        'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
        'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',

        'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
        'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
        'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
        'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',

        'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
        'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
        'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
        'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',

        'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
        'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
        'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
        'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
      }}
    end
  end
end
