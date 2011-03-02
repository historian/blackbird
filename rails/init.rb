
Blackbird.options[:verbose] = true
Blackbird.options[:processors].use 'Blackbird::Processors::IndexedColumns'
Blackbird.options[:processors].use 'Blackbird::Processors::NormalDefault'

groups = [:default, RAILS_ENV.to_sym]
Bundler.definition.specs_for(groups).each do |spec|
  pattern   = File.join(spec.full_gem_path, 'app/schema/**', '*_fragment.rb')
  fragments = Dir.glob(pattern)
  Blackbird.options[:fragments].concat(fragments)
end
