#!/bin/sh

set -e -x

bundle check || bundle --binstubs bin --path .bundle --without darwin,debugger,development
