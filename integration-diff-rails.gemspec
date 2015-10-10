$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "integration_diff_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "integration_diff_rails"
  s.version     = IntegrationDiffRails::VERSION
  s.authors     = ["Yuva"]
  s.email       = ["yuva@codemancers.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of IntegrationDiffRails."
  s.description = "TODO: Description of IntegrationDiffRails."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
end
