#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
make build
echo "built: build/berlin-trip-subway-3sid-v6.0.0.prg"
