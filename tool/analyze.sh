#!/usr/bin/env bash
# Runs static analysis across every package/app in the monorepo using the
# fvm-pinned Flutter SDK. Thin wrapper around the melos "analyze" script -
# see melos.yaml and docs/02_PROJECT_STRUCTURE.md §9.
#
# Prerequisite (one-time, per machine): dart pub global activate melos
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

melos run analyze
