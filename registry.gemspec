# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'registry/version'

Gem::Specification.new do |s|
  s.name          = 'regstry'
  s.version       = Registry::VERSION
  s.authors       = ['Sven Fuchs']
  s.email         = ['me@svenfuchs.com']
  s.homepage      = 'https://github.com/svenfuchs/registry'
  s.licenses      = ['MIT']
  s.summary       = 'Ruby class registry'
  s.description   = 'Allows registering Ruby classes for lookup using a key.'

  s.files         = Dir.glob('{bin/*,lib/**/*,[A-Z]*}')
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ['lib']
end
