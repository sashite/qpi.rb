Gem::Specification.new do |spec|
  spec.name          = 'sashite-gan'
  spec.version       = File.read('VERSION.semver')
  spec.authors       = ['Cyril Wack']
  spec.email         = ['contact@cyril.io']
  spec.summary       = %q{A GAN implementation in Ruby.}
  spec.description   = %q{Implementation of GAN (General Actor Notation) for storing actors from abstract strategy games.}
  spec.homepage      = 'https://github.com/sashite/gan.rb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',  '~> 1.6'
  spec.add_development_dependency 'minitest', '~> 5'
  spec.add_development_dependency 'rake',     '~> 10'
end
