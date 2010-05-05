# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'transitions/version'

Gem::Specification.new do |s|
  s.name        = "transitions"
  s.version     = Transitions::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Simon Menke"]
  s.email       = ["simon.menke@gmail.com"]
  s.homepage    = "http://github.com/fd/transitions"
  s.summary     = "Migrations should be more adaptable"
  s.description = "Transitions are Migrations but then better."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "transitions"

  s.require_path = 'lib'
  s.files        = Dir.glob("{lib}/**/*") +
                   %w(LICENSE README.md ROADMAP.md CHANGELOG.md)
  
  s.add_runtime_dependency     'active_record', '>= 2.3.4'
  s.add_development_dependency 'shoulda',       '>= 2.10.3'
end