#!/bin/bash
set -eo pipefail

python3 -m pip install --upgrade pip setuptools
python3 -m pip install -r requirements.txt
