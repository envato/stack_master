# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stack_master/version'
require 'rbconfig'

Gem::Specification.new do |spec|
  spec.name          = "stack_master"
  spec.version       = StackMaster::VERSION
  spec.authors       = ["Steve Hodgkiss", "Glen Stampoultzis"]
  spec.email         = ["steve@hodgkiss.me", "gstamp@gmail.com"]
  spec.summary       = 'StackMaster is a sure-footed way of creating, updating and keeping track ' \
                       'of Amazon (AWS) CloudFormation stacks.'
  spec.description   = %q{}
  spec.homepage      = "https://opensource.envato.com/projects/stack_master.html"
  spec.license       = "MIT"
  spec.metadata      = {
    "bug_tracker_uri" => "https://github.com/envato/stack_master/issues",
    "changelog_uri" => "https://github.com/envato/stack_master/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://www.rubydoc.info/gems/stack_master/#{spec.version}",
    "source_code_uri" => "https://github.com/envato/stack_master/tree/v#{spec.version}",
  }

  spec.files         = Dir.glob("{bin,lib,stacktemplates}/**/*") + %w(README.md LICENSE.txt)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.4.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "ostruct"
  spec.add_development_dependency "rubocop"
  spec.add_dependency "os"
  spec.add_dependency "ruby-progressbar"
  spec.add_dependency "commander", ">= 4.6.0", "< 6"
  spec.add_dependency "aws-sdk-acm", "~> 1"
  spec.add_dependency "aws-sdk-cloudformation", "~> 1"
  spec.add_dependency "aws-sdk-ec2", "~> 1"
  spec.add_dependency "aws-sdk-identitystore", "~> 1"
  spec.add_dependency "aws-sdk-s3", "~> 1"
  spec.add_dependency "aws-sdk-sns", "~> 1"
  spec.add_dependency "aws-sdk-ssm", "~> 1"
  spec.add_dependency "aws-sdk-ecr", "~> 1"
  spec.add_dependency "aws-sdk-iam", "~> 1"
  spec.add_dependency "sorted_set" # remove once new version of sparkle_formation released (> v3.0.40). See https://github.com/sparkleformation/sparkle_formation/pull/271.
  spec.add_dependency "diffy"
  spec.add_dependency "erubis"
  spec.add_dependency "rainbow"
  spec.add_dependency "activesupport", '>= 4'
  spec.add_dependency "sparkle_formation", "~> 3"
  spec.add_dependency "table_print"
  spec.add_dependency "deep_merge"
  spec.add_dependency "cfndsl", "~> 1"
  spec.add_dependency "multi_json"
  spec.add_dependency "hashdiff", "~> 1"
  spec.add_dependency "ejson_wrapper"
  spec.add_dependency "diff-lcs"
  spec.add_dependency "cfn-nag", ">= 0.6.7", "< 0.9.0"
end
