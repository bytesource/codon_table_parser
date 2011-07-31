require File.expand_path('codontableparser')

describe CodonTableParser do

  describe "On initialization" do

    it "should throw an exception if a file with the wrong content is passed" do
      wrong_file = 'data/dummy.txt'

      lambda do
        CodonTableParser.new(wrong_file)
      end.should raise_error(Exception, "This is not the NCBI genetic code table")
    end

    it "should accept the correct file" do
      correct_file = 'data/codons.txt'

      lambda do
        CodonTableParser.new(correct_file)
      end.should_not raise_error
    end
  end

  describe "Parsing data" do

    before(:each) do
      @file   = 'data/codons.txt'
      @parser = CodonTableParser.new(@file)
    end

    describe "Instance variables" do

      it "@parsed_data should get assigned the parsed content form the 'parse' method" do

        parsed_data = @parser.instance_variable_get(:@parsed_data)

        parsed_data.count.should == 17
        # Check ids
        parsed_data.inject([]) do |result, species|
          result << species[:id]
        end.should == [1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16, 21, 22, 23]

        # Check selected output of some species
        entry1 = parsed_data[0]
        entry1.should == {:id=>1 , :long_name=>"Standard", :short_name=>"SGC0", 
                          :ncbieaa=>"FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG", 
                          :sncbieaa=>"---M---------------M---------------M----------------------------"}

        entry2 = parsed_data[3]
        entry2[:long_name].should  == "Mold Mitochondrial; Protozoan Mitochondrial; Coelenterate Mitochondrial; Mycoplasma; Spiroplasma"
        entry2[:short_name].should == "SGC3"

        entry3 = parsed_data[16]
        entry3[:long_name].should  == "Thraustochytrium Mitochondrial"
        entry3[:short_name].should == nil
      end

      it "@codons should get assigned an array of all codons" do

        @codons = @parser.instance_variable_get(:@codons)

        @codons.each do |codon|
          codon.should =~ /[atcg]{3}/
        end.size.should == 64
      end
    end

    describe "Helper methods" do

      describe "Method: 'table'" do

        it "should return a hash mapping each codon to the correct amino acid" do
          codons  = @parser.instance_variable_get(:@codons)
          ncbieaa = @parser.instance_variable_get(:@parsed_data)[0][:ncbieaa]

          table = @parser.send(:table, codons, ncbieaa)
          # reference_tables = eval(File.read('data/codon_tables_for_rspec.txt'))
          # table.should == reference_tables[1]
          table.should ==
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
      end

      describe "Method: 'prepare_range'" do

        it "should return a sorted set of values" do

          range = @parser.send(:prepare_range, [(1..3), 5, (5..9)])

          range.should == [1, 2, 3, 5, 6, 7, 8, 9]
        end
      end
    end

    describe "Instance methods" do

      describe "Method: 'definitions'" do

        it "should return the correct default output" do

          definitions = @parser.definitions

          definitions.should ==
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

        it "should only return the names for the ids specified with the 'range' option" do
          definitions = @parser.definitions :range => [(1..3), 5]

          definitions.should == 
            {1=>"Standard",
             2=>"Vertebrate Mitochondrial",
             3=>"Yeast Mitochondrial", 
             5=>"Invertebrate Mitochondrial"}
        end

        it "should return the names given in the 'names' option" do

          definitions = @parser.definitions :names => {1 => "hello", 3 => "world"}

          definitions.size.should == 17
          definitions[1].should   == "hello"
          definitions[3].should   == "world"

          definitions2 = @parser.definitions :names =>  {1  => "Standard (Eukaryote)",
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
          definitions2.should == 
            {1  => "Standard (Eukaryote)",
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
      end

      describe "Method 'starts'" do

        it "should return the correct default output" do

          start_codons = @parser.starts
          start_codons.size.should == 17
          start_codons.keys.should == [1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16, 21, 22, 23]
          start_codons.should      == 
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

        it "should only return the start codons for the ids specified in the 'range' option" do

          start_codons = @parser.starts :range => [(1..3), 3, 6, (21..23)]

          start_codons.keys.should == [1, 2, 3, 6, 21, 22, 23]
        end


        it "should add or remove codons as specified in the options" do

          start_codons = @parser.starts 1  => {:add => ['gtg']}, 
            13 => {:remove => ['ttg', 'ata', 'gtg']} 

          start_codons[1].should  == %w(ttg ctg atg gtg)
          start_codons[13].should == %w(atg)

          start_codons2   = @parser.starts 1  => {:add  => ['gtg'], :remove => ['ttg', 'zzz']}

          start_codons2[1].should  == %w(ctg atg gtg)
        end
      end

      describe "Method: 'stops'" do

        it "should return the correct default output" do

          stop_codons = @parser.stops

          stop_codons.size.should == 17
          stop_codons.keys.should == [1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16, 21, 22, 23]
          stop_codons.should      ==
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

        it "should only return the stop_codons for the ids specified with the 'range' option" do
          stop_codons = @parser.stops :range => [(1..3), 3, 6, (21..23)]

          stop_codons.keys.should == [1, 2, 3, 6, 21, 22, 23]
        end

        it "should add or remove codons as specified in the options" do
          stop_codons = @parser.stops 1  => {:add    => ['gtg']}, 
            13 => {:remove => ['taa', 'tag', 'zzz'], :add => ['gcc']} 

          stop_codons[1].should  == %w(taa tag tga gtg)
          stop_codons[13].should == %w(gcc)

          stop_codons2   = @parser.stops 1  => {:add  => ['gtg'], :remove => ['taa', 'zzz']}

          stop_codons2[1].should  == %w(tag tga gtg)
        end

        it "should correctly using both the 'range' option as well as the 'add/remove' option in one method call" do

          stop_codons = @parser.stops :range => [1, 13], 
            1  => {:add    => ['gtg']}, 
            13 => {:remove => ['taa', 'tag', 'zzz'], :add => ['gcc']} 

          stop_codons.size.should == 2
          stop_codons[1].should  == %w(taa tag tga gtg)
          stop_codons[13].should == %w(gcc)
        end
      end

      describe "Method: 'tables'" do

        before(:each) do
          @reference_tables = eval(File.read('data/reference_data/reference_codon_tables.txt'))
        end


        it "should return the correct codon to aa table for each species" do

          tables = @parser.tables

          tables.size.should == 17

          tables.should == @reference_tables
        end

        it " should only return the tables for the ids specified in the options" do

          @tables = @parser.tables :range => [(1..3), 5]

          @tables.size.should == 4
          @tables.each do |key, table|
            table.should == @reference_tables[key]
          end
        end

        describe "Method: 'print'" do

          # it "should print all tables, definitions, start, and stop codons" do
          #   @codons = codons

          #   @all = print @converted, @codons

          #   @all.size.should == 4
          #   @all[0].size.should == 17
          #   @all[1].size.should == 17
          #   @all[2].size.should == 17
          #   @all[3].size.should == 17
          # end

        end
      end
    end
  end
end
