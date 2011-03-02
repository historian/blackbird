
Blackbird.options[:verbose] = true
Blackbird.options[:processors].use 'Blackbird::Processors::IndexedColumns'
Blackbird.options[:processors].use 'Blackbird::Processors::NormalDefault'
