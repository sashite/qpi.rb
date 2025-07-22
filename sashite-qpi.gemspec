# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name        = "sashite-qpi"
  spec.version     = ::File.read("VERSION.semver").chomp
  spec.author      = "Cyril Kato"
  spec.email       = "contact@cyril.email"
  spec.summary     = "QPI (Qualified Piece Identifier) implementation for Ruby with immutable identifier objects"

  spec.description = <<~DESC
    QPI (Qualified Piece Identifier) provides a rule-agnostic format for identifying game pieces
    in abstract strategy board games by combining Style Identifier Notation (SIN) and Piece
    Identifier Notation (PIN) with a colon separator. This gem implements the QPI Specification
    v1.0.0 with a modern Ruby interface featuring immutable identifier objects and functional
    programming principles. QPI represents all four fundamental piece attributes: Type, Side,
    State, and Style. Unlike EPIN which uses derivation markers, QPI explicitly names the style
    for unambiguous identification. Perfect for cross-style matches, game engines, and hybrid
    gaming platforms requiring complete piece identification across multiple game traditions.
  DESC

  spec.homepage    = "https://github.com/sashite/qpi.rb"
  spec.license     = "MIT"
  spec.files       = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version = ">= 3.2.0"

  spec.add_dependency "sashite-pin", "~> 3.0.0"
  spec.add_dependency "sashite-sin", "~> 2.0.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/qpi.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/qpi.rb/main",
    "homepage_uri"          => "https://github.com/sashite/qpi.rb",
    "source_code_uri"       => "https://github.com/sashite/qpi.rb",
    "specification_uri"     => "https://sashite.dev/specs/qpi/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
