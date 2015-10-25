# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stack_master/version'

Gem::Specification.new do |spec|
  spec.name          = "stack_master"
  spec.version       = StackMaster::VERSION
  spec.authors       = ["Steve Hodgkiss", "Glen Stampoultzis"]
  spec.email         = ["steve@hodgkiss.me", "gstamp@gmail.com"]
  spec.summary       = %q{AWS Stack Management}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/envato/stack_master"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
