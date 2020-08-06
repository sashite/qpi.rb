# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name         = 'sashite-gan'
  spec.version      = File.read('VERSION.semver')
  spec.author       = 'Cyril Kato'
  spec.email        = 'contact@cyril.email'
  spec.description  = 'A Ruby interface for data serialization in GAN format ♟️'
  spec.summary      = 'A GAN implementation in Ruby.'
  spec.homepage     = 'https://developer.sashite.com/specs/general-actor-notation'
  spec.license      = 'MIT'
  spec.files        = Dir['LICENSE.md', 'README.md', 'lib/**/*']

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/sashite/gan.rb/issues',
    'documentation_uri' => 'https://rubydoc.info/gems/sashite-gan/index',
    'source_code_uri' => 'https://github.com/sashite/gan.rb',
    'wiki_uri' => 'https://github.com/sashite/gan.rb/wiki'
  }

  spec.add_development_dependency 'brutal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop-performance'
  spec.add_development_dependency 'rubocop-thread_safety'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
end
