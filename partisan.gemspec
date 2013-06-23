# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'partisan/version'

Gem::Specification.new do |spec|
  spec.name          = 'partisan'
  spec.version       = Partisan::VERSION
  spec.authors       = ['Simon Prévost']
  spec.email         = ['sprevost@mirego.com']
  spec.description   = 'Partisan is a Ruby library that allows ActiveRecord records to be follower and followable, just like on popular social networks. It’s heavily inspired by the origin acts_as_follower which is no longer maintened'
  spec.summary       = 'Partisan is a Ruby library that allows ActiveRecord records to be follower and followable'
  spec.homepage      = 'https://github.com/simonprev/partisan'
  spec.license       = 'BSD 3-Clause'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'rails', '>= 3.0.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'sqlite3'
end
