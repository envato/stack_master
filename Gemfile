source 'https://rubygems.org'

# Specify your gem's dependencies in stack_master.gemspec
gemspec

if RUBY_VERSION >= '3.0.0'
  # SparkleFormation has an issue with Ruby 3 and the SortedSet class.
  # Remove after merged: https://github.com/sparkleformation/sparkle_formation/pull/271
  gem 'faux_sorted_set', require: false
end
