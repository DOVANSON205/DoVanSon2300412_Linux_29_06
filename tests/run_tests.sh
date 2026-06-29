#!/usr/bin/env bash
set -euo pipefail

bash -n scripts/de_son.sh
test -f README.md
test -f diagrams/de_son_flow.puml

echo "Kiem tra De Son thanh cong."
