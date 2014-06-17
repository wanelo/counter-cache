# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'counter/cache/version'

Gem::Specification.new do |spec|
  spec.name          = "counter-cache"
  spec.version       = Counter::Cache::VERSION
  spec.authors       = ["Paul Henry & Matt Camuto"]
  spec.email         = ["dev@wanelo.com"]
  spec.summary       = %q{Counting is hard.}
  spec.description   = %q{This makes it easier.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 3.0"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "fakeredis"
  spec.add_development_dependency "sqlite3"
end
