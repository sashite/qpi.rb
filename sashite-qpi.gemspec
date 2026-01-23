# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-qpi"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "QPI (Qualified Piece Identifier) implementation for Ruby with immutable identifier objects"
  spec.description            = "QPI (Qualified Piece Identifier) implementation for Ruby. Provides a rule-agnostic format for complete piece identification in abstract strategy board games by combining SIN and PIN primitives, with Native/Derived relationship support."
  spec.homepage               = "https://github.com/sashite/qpi.rb"
  spec.license                = "Apache-2.0"
  spec.files                  = ::Dir["LICENSE", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "sashite-pin", "~> 4.0.0"
  spec.add_dependency "sashite-sin", "~> 3.0.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/qpi.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/qpi.rb/main",
    "homepage_uri"          => "https://github.com/sashite/qpi.rb",
    "source_code_uri"       => "https://github.com/sashite/qpi.rb",
    "specification_uri"     => "https://sashite.dev/specs/qpi/1.0.0/",
    "wiki_uri"              => "https://sashite.dev/specs/qpi/1.0.0/examples/",
    "funding_uri"           => "https://github.com/sponsors/sashite",
    "rubygems_mfa_required" => "true"
  }
end
