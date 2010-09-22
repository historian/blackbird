require 'bundler'
Bundler::GemHelper.install_tasks

begin
  require 'spec/rake/spectask'
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_files = Dir.glob('specs/**/*_spec.rb')
    t.spec_opts << '--format specdoc'
    t.rcov = false
  end
rescue LoadError
  puts "RSpec not available."
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = FileList['lib/**/*.rb'].to_a
    t.options = ['-m', 'markdown', '--files', FileList['documentation/*.markdown'].to_a.join(',')]
  end
rescue LoadError
  puts "YARD not available. Install it with: sudo gem install yard"
end
