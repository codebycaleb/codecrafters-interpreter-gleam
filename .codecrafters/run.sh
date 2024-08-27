#!/bin/sh
#
# This script is used to run your program on CodeCrafters
#
# This runs after .codecrafters/compile.sh
#
# Learn more: https://codecrafters.io/program-interface

set -e # Exit on failure
set -o pipefail # Prevent masking pipe failures

# TODO: Use --no-print-progress once https://github.com/gleam-lang/gleam/issues/2299 is implemented
exec gleam run --module lox -- "$@" | grep -v "Compiled in" | grep -v "Running lox.main"
