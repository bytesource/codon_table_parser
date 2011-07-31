CodonTableParser

Parses the NCBI genetic code table, generating hash maps of each species' name, start codons, stop codons and codon table. 
The output can be customized easily and used to update the respective constants of BioRuby's CodonTable class whenever the original data changes.



The first line of the file is read to determine if the content is correct. If not, an exception is thrown:


Instance Methods

Every method can take a :range option that specifies the ids of the species to be considered in the output. 
A range is specified as an array of integers, Ranges or both. 
Example:
:range => [(1..3), 5, 9] # converted internally to [1, 2, 3, 5, 9]
ids not present in the originial data are ignored.

Besides the :range option, several methods also take other options as demonstrated below.

definitions

# Return default hash map of names
definitions = parser.definitions

definitions
# {1=>"Standard",
#  2=>"Vertebrate Mitochondrial",
#  3=>"Yeast Mitochondrial",
#  4=>"Mold Mitochondrial; Protozoan Mitochondrial; Coelenterate Mitochondrial; Mycoplasma; Spiroplasma",
#  5=>"Invertebrate Mitochondrial",
#  6=>"Ciliate Nuclear; Dasycladacean Nuclear; Hexamita Nuclear",
#  9=>"Echinoderm Mitochondrial; Flatworm Mitochondrial",
#  10=>"Euplotid Nuclear",
#  11=>"Bacterial and Plant Plastid",
#  12=>"Alternative Yeast Nuclear",
#  13=>"Ascidian Mitochondrial",
#  14=>"Alternative Flatworm Mitochondrial",
#  15=>"Blepharisma Macronuclear",
#  16=>"Chlorophycean Mitochondrial",
#  21=>"Trematode Mitochondrial",
#  22=>"Scenedesmus obliquus Mitochondrial",
#  23=>"Thraustochytrium Mitochondrial"}

# Return the names names for the ids specified in :range
definitions = parser.definitions :range => [(1..3), 5, 9]
# Return default hash map with custom names for the ids 1 and 3
definitions = parser.definitions :names => {1  => "Standard (Eukaryote)",
                                            3  => "Yeast Mitochondorial"}
definitions[1]
# "Standard (Eukaryote)"
definitions[3]
# "Yeast Mitochondorial"

# Return the names for the ids specified in :range, with custom names for the ids 1 and 3
parser.definitions :names => :range => [(1..3), 5, 9],
                             {1  => "Standard (Eukaryote)",
                              3  => "Yeast Mitochondorial"}

starts

# Return default hash map of start codons
start_codons = parser.starts

start_codons
# {1=>["ttg", "ctg", "atg"],
#  2=>["att", "atc", "ata", "atg", "gtg"],
#  3=>["ata", "atg"],
#  4=>["tta", "ttg", "ctg", "att", "atc", "ata", "atg", "gtg"],
#  5=>["ttg", "att", "atc", "ata", "atg", "gtg"],
#  6=>["atg"],
#  9=>["atg", "gtg"],
#  10=>["atg"],
#  11=>["ttg", "ctg", "att", "atc", "ata", "atg", "gtg"],
#  12=>["ctg", "atg"],
#  13=>["ttg", "ata", "atg", "gtg"],
#  14=>["atg"],
#  15=>["atg"],
#  16=>["atg"],
#  21=>["atg", "gtg"],
#  22=>["atg"],
#  23=>["att", "atg", "gtg"]}

# Return the start codons for the ids specified in :range
start_codons = parser.starts :range => [(1..3), 5, 9]

# Add or remove start codons as necessary
start_codons = parser.starts 1  => {:add => ['gtg']}, 
                             13 => {:remove => ['ttg', 'ata', 'gtg']} 

start_codons[1]
# ["ttg", "ctg", "atg", "gtg"]
start_codons[13]
# ["atg"]

# Return the start codons for the ids specified with :range, add or remove codons from specific ids
start_codons = parser.starts :range => [(1..3), 13],
                             1  => {:add => ['gtg']}, 
                             13 => {:remove => ['ttg', 'ata', 'gtg']} 


stops

stop_codons = parser.stops

# Return the default hash map of stop codons
stops
# {1=>["taa", "tag", "tga"],
#  2=>["taa", "tag", "aga", "agg"],
#  3=>["taa", "tag"],
#  4=>["taa", "tag"],
#  5=>["taa", "tag"],
#  6=>["tga"],
#  9=>["taa", "tag"],
#  10=>["taa", "tag"],
#  11=>["taa", "tag", "tga"],
#  12=>["taa", "tag", "tga"],
#  13=>["taa", "tag"],
#  14=>["tag"],
#  15=>["taa", "tga"],
#  16=>["taa", "tga"],
#  21=>["taa", "tag"],
#  22=>["tca", "taa", "tga"],
#  23=>["tta", "taa", "tag", "tga"]}


# Return the stop codons for the ids specified with :range
stop_codons = parser.stops :range => [(1..3), 5, 9]

# Add or remove stop codons as necessary

stop_codons = @parser.stops 1  => {:add  => ['gtg'], :remove => ['taa']},
                            13 => {:remove => ['taa', 'tag'], :add => ['gcc']} 

stop_codons[1] = ["tag", "tga", "gtg"]
stop_codons[13] = ["gcc"]


# Return the stop codons for the ids specified with :range, add or remove codons from specific ids
stop_codons = @parser.stops :range => [(1..3), 5, 13],
                            1  => {:add  => ['gtg'], :remove => ['taa']},
                            13 => {:remove => ['taa', 'tag'], :add => ['gcc']}

tables

# Return codon tables of all species
codon_tables = parser.tables

tables
# {
#     # codon table 1
#     1 => {
#       'ttt' => 'F', 'tct' => 'S', 'tat' => 'Y', 'tgt' => 'C',
#       'ttc' => 'F', 'tcc' => 'S', 'tac' => 'Y', 'tgc' => 'C',
#       'tta' => 'L', 'tca' => 'S', 'taa' => '*', 'tga' => '*',
#       'ttg' => 'L', 'tcg' => 'S', 'tag' => '*', 'tgg' => 'W',
# 
#       'ctt' => 'L', 'cct' => 'P', 'cat' => 'H', 'cgt' => 'R',
#       'ctc' => 'L', 'ccc' => 'P', 'cac' => 'H', 'cgc' => 'R',
#       'cta' => 'L', 'cca' => 'P', 'caa' => 'Q', 'cga' => 'R',
#       'ctg' => 'L', 'ccg' => 'P', 'cag' => 'Q', 'cgg' => 'R',
# 
#       'att' => 'I', 'act' => 'T', 'aat' => 'N', 'agt' => 'S',
#       'atc' => 'I', 'acc' => 'T', 'aac' => 'N', 'agc' => 'S',
#       'ata' => 'I', 'aca' => 'T', 'aaa' => 'K', 'aga' => 'R',
#       'atg' => 'M', 'acg' => 'T', 'aag' => 'K', 'agg' => 'R',
# 
#       'gtt' => 'V', 'gct' => 'A', 'gat' => 'D', 'ggt' => 'G',
#       'gtc' => 'V', 'gcc' => 'A', 'gac' => 'D', 'ggc' => 'G',
#       'gta' => 'V', 'gca' => 'A', 'gaa' => 'E', 'gga' => 'G',
#       'gtg' => 'V', 'gcg' => 'A', 'gag' => 'E', 'ggg' => 'G',
#     },
# 
#     # codon table 2
#     2 => { ... },
#     3 => { ... },
#     ...
#     23 => { ... }
# }

# Return the codon tables for the ids specified with :range

codon_tables = parser.tables :range => [(1..3), 5, 9, 23]


bundle

# Return the definitions, codon table, start and stop codons for all species as a hash map
bundle = parser.bundle

bundle
{:definitions => # return value of the 'definitions' method
 :starts      => # return value of the 'starts' method
 :stops       => # return value of the 'stops' method
 :tables      => # return value of the 'tables' method
}












The values of the BioRuby's CodonTable

 bundle = @parser.bundle :names => {1  => "Standard (Eukaryote)",
                                               4  => "Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma",
                                               3  => "Yeast Mitochondorial",
                                               6  => "Ciliate Macronuclear and Dasycladacean",
                                               9  => "Echinoderm Mitochondrial",
                                               11 => "Bacteria",
                                               14 => "Flatworm Mitochondrial",
                                               22 => "Scenedesmus obliquus mitochondrial"},
                                               :starts => {1  => {:add    => ['gtg']}, 
                                                           13 => {:remove => ['ttg', 'ata', 'gtg']}}

