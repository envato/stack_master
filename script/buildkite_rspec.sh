#!/bin/bash

set -e

echo
echo "--- Cleaning up working tree"
echo

time ./script/builkite/clean.sh

echo
echo "--- Bundling"
echo

time ./script/buildkite/bundle.sh

echo
echo "+++ Running rspec"
echo

time ./bin/rspec
