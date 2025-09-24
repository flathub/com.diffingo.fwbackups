#!/bin/sh

python3 -m pip install -U --user uv
uv export --frozen --no-dev --no-emit-workspace --format requirements.txt --no-hashes -o requirements.txt --project ../fwbackups

# do not use flatpak-pip-generator; it cannot download binary wheels which is required for cryptograph
# https://github.com/johannesjh/req2flatpak?tab=readme-ov-file#related-work
python3 -m pip install -U --user git+https://github.com/johannesjh/req2flatpak
req2flatpak --requirements-file requirements.txt --target-platforms 313-{x86_64,aarch64} >python3-modules.json
