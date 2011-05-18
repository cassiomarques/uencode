# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "uencode/version"

Gem::Specification.new do |s|
  s.name        = "uencode"
  s.version     = Uencode::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Cássio Marques"]
  s.email       = ["cassiommc@gmail.com"]
  s.homepage    = "http://github.com/cassiomarques/uencode"
  s.summary     = %q{Simple UEncode API client written in Ruby}
  s.description = %q{UEncode API client}

  s.rubyforge_project = "uencode"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "2.6.0"
  s.add_development_dependency "vcr", "1.9.0"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "growl"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "webmock"

  s.add_dependency "nokogiri", "1.4.4"
  s.add_dependency "typhoeus"
end
