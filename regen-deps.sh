#!/bin/sh
# Regenerate python3-modules.json from the fwbackups uv.lock.
#
# Requirements: uv, flatpak, and the SDK below installed
# (flatpak install flathub org.gnome.Sdk//51).
#
# Usage: ./regen-deps.sh [path-to-fwbackups-checkout]   (default: ../fwbackups)
set -eu

FWBACKUPS_DIR=${1:-../fwbackups}
RUNTIME=org.gnome.Sdk//51
# Pinned flatpak-builder-tools commit; bump deliberately.
FBT_COMMIT=9d86d336a39b9af38b86f114b6ce5820fe260f91
PIP_GENERATOR="https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/${FBT_COMMIT}/pip/flatpak-pip-generator.py"

# requirements.txt is an intermediate file; uv.lock is the source of truth.
REQS=$(mktemp)
trap 'rm -f "$REQS"' EXIT

# PyGObject and pycairo are provided by the GNOME runtime, so they are not bundled.
uv export --frozen --no-dev --no-emit-project --no-hashes --no-header --no-annotate \
    --no-emit-package pygobject --no-emit-package pycairo \
    --format requirements.txt --project "$FWBACKUPS_DIR" \
    | sed -e 's/ *;.*//' -e '/^\s*#/d' -e '/^\s*$/d' > "$REQS"

# cryptography and bcrypt are Rust extensions, so use the PyPI wheels for them
# (as most Flathub apps do). Everything else is built from source.
uv run "$PIP_GENERATOR" \
    --runtime="$RUNTIME" \
    --requirements-file="$REQS" \
    --prefer-wheels=cryptography,bcrypt \
    --output=python3-modules
