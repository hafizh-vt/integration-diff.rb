$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "integration_diff/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "integration-diff"
  s.version     = IntegrationDiff::VERSION
  s.authors     = ["Yuva"]
  s.email       = ["yuva@codemancers.com"]
  s.homepage    = "http://diff.codemancers.com"
  s.summary     = "Rails integration for integration diff service"
  s.description = "Rails integration for integration diff service"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "Readme.md"]

  s.add_dependency "faraday"
  s.add_dependency "slack_notifier"
end
