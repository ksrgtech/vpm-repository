#!/bin/bash

die() {
  echo "$@" >&2
  exit 1
}

version="$1"

if [ -z "$version" ]; then
  die "Version is required"
fi

sha256sum_file_url="https://github.com/KisaragiEffective/ResoniteImportHelper/releases/download/${version}/vpm-src.zip.sha256sum"
version_manifest_file_url="https://raw.githubusercontent.com/KisaragiEffective/ResoniteImportHelper/refs/tags/${version}/package.json"
echo "version: $version"
echo "GET $sha256sum_file_url"
sha256sum="$(curl -sSL "$sha256sum_file_url" | tr -d '\n')"
echo "GET $version_manifest_file_url"
zip_download_url="https://github.com/KisaragiEffective/ResoniteImportHelper/releases/download/$version/vpm-src.zip"
echo "ZIP is on $zip_download_url"
version_manifest="$(
  curl -sSL "$version_manifest_file_url" \
  | jq \
    --arg zip_download_url "$zip_download_url" \
    --arg sha256 "$sha256sum" \
    'del(.author, .repository, .keywords, .license) | .url = $zip_download_url | .zipSHA256 = $sha256'
)"

base="$(dirname "$0")/.."
src="$base/index.json"
tmp="$(mktemp)"

jq \
  --arg version "$version" \
  --argjson version_manifest "$version_manifest" \
  '.packages["io.github.kisaragieffective.resonite-import-helper"].versions[$version] = $version_manifest' \
  < "$src" > "$tmp"

mv "$tmp" "$src"
