# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "railshoster/version"

Gem::Specification.new do |s|
  s.name        = "railshoster"
  s.version     = Railshoster::VERSION
  s.authors     = ["Julian Fischer"]
  s.email       = ["fischer@enterprise-rails.de"]
  s.homepage    = "http://www.railshoster.com"
  s.summary     = %q{RailsHoster Application Deployment Suite}
  s.description = %q{Easily deploy your Rails app to RailsHoster.com by using this gem.}

  s.rubyforge_project = "railshoster"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "bundler", ">= 1.0.15"
  s.add_dependency "capistrano"#, "~> 3.0"
  s.add_dependency "net-sftp"
  s.add_dependency "highline"
  s.add_dependency "gli", ">= 1.2.5"
  s.add_dependency "json"
  s.add_dependency "git"
  s.add_dependency "erubis"
  s.add_dependency "activesupport"
  
  s.add_development_dependency('rspec')
  s.add_development_dependency('fakefs')
  s.add_development_dependency('mocha')
end
