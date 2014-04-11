# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require 'Birst_Command/version'

Gem::Specification.new do |s|
  s.name        = "Birst_Command"
  s.version     = Birst_Command::VERSION
  s.authors     = ["Sterling Paramore"]
  s.email       = ["gnilrets@gmail.com"]
  s.homepage    = "https://github.com/gnilrets"
  s.license     = "MIT"
  s.summary     = "Birst Command"
  s.description = "Ruby interface to Birst web API"
  s.rubyforge_project = "Birst_Command"

  s.required_ruby_version = '~> 2'
  s.add_runtime_dependency "savon", ["~> 2.0"]
  s.add_runtime_dependency "httpclient", ["~> 2.3"]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
