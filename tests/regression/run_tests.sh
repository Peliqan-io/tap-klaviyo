#!/usr/bin/env bash
# Run regression tests inside a Python 3.11 container.

set -euo pipefail

TAP_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

echo "==> Running regression tests in python:3.11-slim"
echo "    Tap dir: $TAP_DIR"

docker run --rm \
  -v "$TAP_DIR":/tap \
  -w /tap \
  -e TAP_KLAVIYO_API_KEY="${TAP_KLAVIYO_API_KEY:?}" \
  -e TAP_KLAVIYO_START_DATE="${TAP_KLAVIYO_START_DATE:-2024-01-01T00:00:00Z}" \
  -e TAP_KLAVIYO_INCLUDE_STREAMS="${TAP_KLAVIYO_INCLUDE_STREAMS:-lists,global_exclusions}" \
  -e AES_SECRET_KEY="peliqan-test-key" \
  python:3.11-slim \
  bash -c "
    apt-get update -qq && apt-get install -y -qq git > /dev/null
    python -m venv /venv
    /venv/bin/pip install -e . pytest -q
    cd tests/regression && /venv/bin/python -m pytest test_regression.py -v
  "
