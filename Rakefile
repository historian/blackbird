require 'bundler'
Bundler::GemHelper.install_tasks

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = ['-O', 'spec/spec.opts']
end

require 'yard'
YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

task :default  => :spec