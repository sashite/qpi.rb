# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "sashite-qpi"
  spec.version = ::File.read("VERSION.semver").chomp
  spec.author  = "Cyril Kato"
  spec.email   = "contact@cyril.email"
  spec.summary = "QPI (Qualified Piece Identifier) implementation for Ruby with immutable identifier objects"

  spec.description = <<~DESC
    QPI (Qualified Piece Identifier) provides a rule-agnostic format for identifying game pieces
    in abstract strategy board games by combining Style Identifier Notation (SIN) and Piece
    Identifier Notation (PIN) primitives. This gem implements the QPI Specification v1.0.0 with
    a modern Ruby interface featuring immutable identifier objects and functional programming
    principles. QPI enables complete piece identification with all four fundamental attributes
    (family, type, side, state) while supporting cross-style gaming environments. Perfect for
    multi-tradition board games, hybrid gaming systems, and game engines requiring comprehensive
    piece identification across different game styles and traditions.
  DESC

  spec.homepage               = "https://github.com/sashite/qpi.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  # Runtime dependencies on foundational primitives
  spec.add_dependency "sashite-pin", "~> 3.2.0"
  spec.add_dependency "sashite-sin", "~> 2.1.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/qpi.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/qpi.rb/main",
    "homepage_uri"          => "https://github.com/sashite/qpi.rb",
    "source_code_uri"       => "https://github.com/sashite/qpi.rb",
    "specification_uri"     => "https://sashite.dev/specs/qpi/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
