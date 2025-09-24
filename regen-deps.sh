#!/bin/sh

wget --continue https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/refs/heads/master/pip/flatpak-pip-generator.py
python3 -m pip install -U --user uv requirements-parser
uv export --frozen --no-dev --no-emit-workspace --format requirements.txt -o requirements.txt --project ../fwbackups
python3 flatpak-pip-generator.py --pyproject-file=../fwbackups/pyproject.toml --runtime org.gnome.Platform//49
