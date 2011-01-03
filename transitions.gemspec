# -*- encoding: utf-8 -*-
require File.expand_path("../lib/opts/version", __FILE__)

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

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "shoulda", ">= 2.10.3"
  s.add_runtime_dependency "activerecord", ">= 3.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
