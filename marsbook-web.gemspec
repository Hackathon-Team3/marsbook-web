# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marsbook/version'

Gem::Specification.new do |spec|
  spec.name          = "marsbook"
  spec.version       = Marsbook::VERSION
  spec.authors       = ["Nicholas Terry"]
  spec.email         = ["nick.i.terry@gmail.com"]
  spec.summary       = %q{RESTful frontend for MarsBook}
  spec.description   = %q{RESTful frontend for MarsBook}
  spec.homepage      = ""
  spec.license       = "Apache2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sinatra", "~> 1.4.5"
  #spec.add_dependency "pg", "~> 0.17.1"
  spec.add_dependency "mysql", "~> 2.9.1"
  spec.add_dependency "activerecord", "~> 4.1.7"
  spec.add_dependency "json_pure", "~> 1.8.1"
  spec.add_dependency "aws-sdk", "~> 1.58.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
