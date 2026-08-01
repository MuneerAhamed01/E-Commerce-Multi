#!/usr/bin/env bash
# Checks (or with --fix, applies) formatting across every package/app in the
# monorepo. Thin wrapper around the melos "format"/"format:fix" scripts - see
# melos.yaml and docs/02_PROJECT_STRUCTURE.md §9.
#
# Prerequisite (one-time, per machine): dart pub global activate melos
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ "${1:-}" == "--fix" ]]; then
  melos run format:fix
else
  melos run format
fi
