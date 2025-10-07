#!/bin/bash
set -e

ID="$(jq -r '.name' ./package.json)"
DEST="$HOME/.local/share/ksysguard/sensorfaces/$ID"

cp -r ./contents ./dist

rm -r "$DEST" || true
cp -r "./dist/" "$DEST"
