$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sunspot_association/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sunspot_association"
  s.version     = SunspotAssociation::VERSION
  s.authors     = ["Arjen Oosterkamp"]
  s.email       = ["mail@arjen.me"]
  s.homepage    = ""
  s.summary     = %q{Automatic association (re)indexing for your searchable Sunspot models.}
  s.description = %q{Automatic association (re)indexing for your searchable Sunspot models.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 2.3"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "sunspot_test"
  s.add_development_dependency "coveralls"

  s.add_dependency "activerecord", "~> 3.0"
  s.add_dependency "sunspot_rails"
end
