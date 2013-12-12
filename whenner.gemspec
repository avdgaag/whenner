# -*- encoding: utf-8 -*-
require File.expand_path('../lib/whenner/version', __FILE__)

Gem::Specification.new do |s|
  # Metadata
  s.name        = 'whenner'
  s.version     = Whenner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Arjan van der Gaag']
  s.email       = %q{arjan@arjanvandergaag.nl}
  s.description = %q{A simple promises implementation in Ruby.}
  s.homepage    = %q{http://avdgaag.github.com/whenner}
  s.summary     = <<-EOS
A promise represents the eventual result of an asynchronous operation. The
primary way of interacting with a promise is through its `done` and `fail`
methods, which registers callbacks to receive either a promise’s eventual value
or the reason why the promise cannot be fulfilled.
EOS

  # Files
  s.files         = `git ls-files`.split("
")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("
")
  s.executables   = `git ls-files -- bin/*`.split("
").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Rdoc
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = [
     'LICENSE',
     'README.md',
     'HISTORY.md'
  ]

  # Dependencies
  s.add_development_dependency 'kramdown'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
end
