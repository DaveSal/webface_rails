$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "webface_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name          = "webface_rails"
  spec.version       = WebfaceRails::VERSION
  spec.authors       = ["Roman Snitko"]
  spec.email         = ["roman.snitko@gmail.com"]

  spec.summary       = %q{Webface.js integration for Ruby On Rails}
  spec.description   = %q{Provides view helpers for creating components, standard component views and css, form builder and a unit test server}
  spec.homepage      = "https://webfacejs.org"
  spec.license       = "MIT"

  spec.files = Dir["app/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.add_dependency "rails", "~> 5.2.2"
end
