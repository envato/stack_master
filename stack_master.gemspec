# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stack_master/version'
require 'rbconfig'

windows_build = RbConfig::CONFIG['host_os'] =~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/

if windows_build
  gem_platform = 'current'
else
  gem_platform = Gem::Platform::RUBY
end


Gem::Specification.new do |spec|
  spec.name          = "stack_master"
  spec.version       = StackMaster::VERSION
  spec.authors       = ["Steve Hodgkiss", "Glen Stampoultzis"]
  spec.email         = ["steve@hodgkiss.me", "gstamp@gmail.com"]
  spec.summary       = %q{StackMaster is a sure-footed way of creating, updating and keeping track of Amazon (AWS) CloudFormation stacks.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/envato/stack_master"
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib,stacktemplates}/**/*") + %w(README.md)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.1.0"
  spec.platform      = gem_platform

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "timecop"
  spec.add_dependency "os"
  spec.add_dependency "ruby-progressbar"
  spec.add_dependency "commander", "<= 4.4.5"
  spec.add_dependency "aws-sdk-acm", "~> 1"
  spec.add_dependency "aws-sdk-cloudformation", "~> 1"
  spec.add_dependency "aws-sdk-ec2", "~> 1"
  spec.add_dependency "aws-sdk-s3", "~> 1"
  spec.add_dependency "aws-sdk-sns", "~> 1"
  spec.add_dependency "aws-sdk-ssm", "~> 1"
  spec.add_dependency "aws-sdk-ecr", "~> 1"
  spec.add_dependency "diffy"
  spec.add_dependency "erubis"
  spec.add_dependency "colorize"
  spec.add_dependency "activesupport", '>= 4'
  spec.add_dependency "sparkle_formation"
  spec.add_dependency "table_print"
  spec.add_dependency "deep_merge"
  spec.add_dependency "cfndsl"
  spec.add_dependency "multi_json"
  spec.add_dependency "hashdiff"
  spec.add_dependency "dotgpg" unless windows_build
  spec.add_dependency "diff-lcs" if windows_build
end
