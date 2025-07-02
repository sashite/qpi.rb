# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = "sashite-gan"
  spec.version     = ::File.read("VERSION.semver").chomp
  spec.author      = "Cyril Kato"
  spec.email       = "contact@cyril.email"
  spec.summary     = "GAN (General Actor Notation) implementation for Ruby - board game piece identification"
  spec.description = "A Ruby implementation of GAN (General Actor Notation) v1.0.0 specification for " \
                     "identifying game actors in abstract strategy board games. GAN combines Style Name " \
                     "Notation (SNN) and Piece Identifier Notation (PIN) with a colon separator to provide " \
                     "complete, unambiguous piece identification. Represents all four fundamental piece " \
                     "attributes: Type, Side, State, and Style. Enables cross-style gaming, immutable " \
                     "transformations, and component extraction with to_pin/to_snn methods. Built on " \
                     "sashite-snn and sashite-pin gems."
  spec.homepage    = "https://github.com/sashite/gan.rb"
  spec.license     = "MIT"
  spec.files       = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version = ">= 3.2.0"

  spec.add_dependency "sashite-pin", "~> 2.0.2"
  spec.add_dependency "sashite-snn", "~> 1.1.1"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/gan.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/gan.rb/main",
    "homepage_uri"          => "https://github.com/sashite/gan.rb",
    "source_code_uri"       => "https://github.com/sashite/gan.rb",
    "specification_uri"     => "https://sashite.dev/specs/gan/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
