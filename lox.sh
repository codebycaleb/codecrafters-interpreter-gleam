#!/bin/sh
#
# Use this script to run your program LOCALLY.
#
# Note: Changing this script WILL NOT affect how CodeCrafters runs your program.
#
# Learn more: https://codecrafters.io/program-interface
set -e # Exit on failure
set -o pipefail # Prevent masking pipe failures

# TODO: Use --no-print-progress once https://github.com/gleam-lang/gleam/issues/2299 is implemented
exec gleam run --module lox -- "$@" | { grep -v "Compiled in" || true; } | { grep -v "Running lox.main" || true; }