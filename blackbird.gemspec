# -*- encoding: utf-8 -*-
require File.expand_path("../lib/blackbird/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "blackbird"
  s.version     = Blackbird::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Simon Menke"]
  s.email       = ["simon.menke@gmail.com"]
  s.homepage    = "http://github.com/fd/blackbird"
  s.summary     = "Migrations should be more adaptable"
  s.description = "Blackbird are Migrations but then better."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "blackbird"

  s.add_runtime_dependency "activerecord", ">= 2.3.4"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
