#!/usr/bin/env bash
# Point this clone at the committed hooks under .githooks/
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

git config core.hooksPath .githooks
chmod +x .githooks/pre-commit

echo "Git hooks path set to .githooks (pre-commit will run SwiftLint + SwiftFormat)."
echo "Tools required: brew install swiftlint swiftformat"
