#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "built: build/berlin-trip-subway-3sid.prg"
