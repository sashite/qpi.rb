# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name                   = "sashite-gan"
  spec.version                = ::File.read("VERSION.semver").chomp
  spec.author                 = "Cyril Kato"
  spec.email                  = "contact@cyril.email"
  spec.summary                = "GAN (General Actor Notation) support for the Ruby language."
  spec.description            = "A Ruby interface for serialization and deserialization of game actors in GAN format. " \
                                "GAN is a consistent and rule-agnostic format for representing game actors in abstract " \
                                "strategy board games, providing a standardized way to identify pieces with their " \
                                "originating game."
  spec.homepage               = "https://github.com/sashite/gan.rb"
  spec.license                = "MIT"
  spec.files                  = ::Dir["LICENSE.md", "README.md", "lib/**/*"]
  spec.required_ruby_version  = ">= 3.2.0"

  spec.add_dependency "pnn", "~> 2.0.0"
  spec.add_dependency "sashite-snn", "~> 1.0.0"

  spec.metadata = {
    "bug_tracker_uri"       => "https://github.com/sashite/gan.rb/issues",
    "documentation_uri"     => "https://rubydoc.info/github/sashite/gan.rb/main",
    "homepage_uri"          => "https://github.com/sashite/gan.rb",
    "source_code_uri"       => "https://github.com/sashite/gan.rb",
    "specification_uri"     => "https://sashite.dev/documents/gan/1.0.0/",
    "rubygems_mfa_required" => "true"
  }
end
