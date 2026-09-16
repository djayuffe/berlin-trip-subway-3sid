#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
cd src
acme -f cbm -o ../build/subway_3sid_v60.prg subway.s
echo "built: mega/build/subway_3sid_v60.prg"
