# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "railshoster/version"

Gem::Specification.new do |s|
  s.name        = "railshoster"
  s.version     = Railshoster::VERSION
  s.authors     = ["Julian Fischer"]
  s.email       = ["fischer@enterprise-rails.de"]
  s.homepage    = "http://www.railshoster.com"
  s.summary     = %q{RailsHoster Applicatoin Deployment Suite}
  s.description = %q{Easily deploy your Rails app to RailsHoster.com by using this gem.}

  s.rubyforge_project = "railshoster"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency "capistrano"
  s.add_dependency "capistrano-ext"
  s.add_dependency "gli", ">= 1.2.5"
end
