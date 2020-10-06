# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "jekyll-titles-from-content/version"

Gem::Specification.new do |s|
  s.name          = "jekyll-titles-from-content"
  s.version       = JekyllTitlesFromContent::VERSION
  s.authors       = ["Colin Seymour"]
  s.email         = ["colin@symr.io"]
  s.homepage      = "https://github.com/lildude/jekyll-titles-from-content"
  s.summary       = "A Jekyll plugin to pull the page title from the first " \
                    "X words of the content, when none is specified."
  s.files         = `git ls-files lib *.md`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ["lib"]
  s.license       = "MIT"

  s.add_dependency "jekyll", ">= 3.3", "< 5.0"
  s.add_development_dependency "minitest"
  s.add_development_dependency "rubocop", "~> 0.71"
  s.add_development_dependency "rubocop-jekyll", "~> 0.10"
  s.add_development_dependency "simplecov", "~> 0.19"
end
