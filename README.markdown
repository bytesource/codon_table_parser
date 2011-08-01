# CodonTableParser

Parses the [NCBI genetic code](ftp://ftp.ncbi.nih.gov/entrez/misc/data/gc.prt) table with a multiline Regex, generating hash maps of each species' name, start codons, stop codons and codon table. 
The output can be easily customized and used to update the respective constants of BioRuby's [CodonTable](https://github.com/bioruby/bioruby/blob/master/lib/bio/data/codontable.rb) class whenever the original data changes.

## Usage

``` ruby
file = 'path/to/genetic_code.txt'
parser = CodonTableParser(file)
```

The first line of the file is read to determine if the content is correct. If not, an exception is thrown:

``` ruby
file = 'path/to/file_with_wrong_content.txt'
parser = CodonTableParser(file)
# Exception: This is not the NCBI genetic code table
```

### Instance Methods

The following instance methods are available:

* CodonTableParser#definitions
* CodonTableParser#starts
* CodonTableParser#stops
* CodonTableParser#tables
* CodonTableParser#bundle

Every intance method can take a *:range* option that specifies the ids of the species to be considered in the output. 
A range is specified as an array of integers, Ranges or both. 
Example:

``` ruby
:range => [(1..3), 5, 9] # converted internally to [1, 2, 3, 5, 9]

```
ids not present in the originial data are ignored.
Besides the *:range* option, several methods also take other options as demonstrated below.

#### CodonTableParser#definitions

``` ruby

parser = CodonTableParser(file)

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
parser.definitions :range => [(1..3), 5, 9],
                   :names => {1 => "Standard (Eukaryote)",
                              3 => "Yeast Mitochondorial"}

```

#### CodonTableParser#starts

``` ruby

parser = CodonTableParser(file)

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

# Alternative syntax, normally only used in the bundle method described below
start_codons = parser.starts :starts => {1  => {:add => ['gtg']}, 
                                         13 => {:remove => ['ttg', 'ata', 'gtg']}} 

# Return the start codons for the ids specified with :range, add or remove codons from specific ids
start_codons = parser.starts :range => [(1..3), 13],
                             1  => {:add => ['gtg']}, 
                             13 => {:remove => ['ttg', 'ata', 'gtg']} 

```                           

#### CodonTableParser#stops

``` ruby

parser = CodonTableParser(file)

# Return the default hash map of stop codons
stop_codons = parser.stops

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

stop_codons = parser.stops 1  => {:add => ['gtg'], :remove => ['taa']},
                           13 => {:add => ['gcc'], :remove => ['taa', 'tag']} 

stop_codons[1]
# ["tag", "tga", "gtg"]
stop_codons[13]
# ["gcc"]

# Alternative syntax, normally only used in the bundle method described below
stop_codons = parser.stops :stops => {1  => {:add => ['gtg'], :remove => ['taa']},
                                      13 => {:add => ['gcc'], :remove => ['taa', 'tag']}}


# Return the stop codons for the ids specified with :range, add or remove codons from specific ids
stop_codons = parser.stops :range => [(1..3), 5, 13],
                            1  => {:add => ['gtg'], :remove => ['taa']},
                            13 => {:add => ['gcc'], :remove => ['taa', 'tag']}

```

#### CodonTableParser#tables

``` ruby

parser = CodonTableParser(file)

# Return codon tables of all species
codon_tables = parser.tables

tables
# {
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
#     2 => { ... },
#     3 => { ... },
#     ...
#     23 => { ... }
# }

# Return the codon tables for the ids specified with :range
codon_tables = parser.tables :range => [(1..3), 5, 9, 23]

```

#### CodonTableParser#bundle

``` ruby

parser = CodonTableParser(file)

# Return the definitions, codon table, start and stop codons for all species as a hash map
bundle = parser.bundle

bundle
# {:definitions => {return value of the 'definitions' method}
#  :starts      => {return value of the 'starts' method}
#  :stops       => {return value of the 'stops' method}
#  :tables      => {return value of the 'tables' method}
# }

```
The *bundle* method accepts all options from the methods described above, that is:

* :range  (applied to all methods) 
* :names  (applied to the *definitions* method) 
* :starts (applied to the *starts* method)
* :stops  (applied to the *stops* method)


To return the same values as are assigned to the constants *DEFINITIONS*, *STARTS*, *STOPS*, and *TABLES* of BioRuby's [CodonTable](https://github.com/bioruby/bioruby/blob/master/lib/bio/data/codontable.rb) class, calling *bundle* with the following options will do:

``` ruby
bundle = parser.bundle :names  => {1  => "Standard (Eukaryote)",
                                   4  => "Mold, Protozoan, Coelenterate Mitochondrial and Mycoplasma/Spiroplasma",
                                   3  => "Yeast Mitochondorial",
                                   6  => "Ciliate Macronuclear and Dasycladacean",
                                   9  => "Echinoderm Mitochondrial",
                                   11 => "Bacteria",
                                   14 => "Flatworm Mitochondrial",
                                   22 => "Scenedesmus obliquus mitochondrial"},
                       :starts => {1  => {:add    => ['gtg']}, 
                                   13 => {:remove => ['ttg', 'ata', 'gtg']}}

```
