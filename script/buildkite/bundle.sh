#!/bin/sh

set -e -x

bundle check || bundle --deployment --binstubs bin --path .bundle --without darwin,debugger,development
