#!/bin/sh
# Packs an XMB icon directory into <dir>.tar, shrunk to the size the
# 3DS menu draws them at, for xmb.c to read in one go.
#
# usage: ctr-pack-xmb-icons.sh <assets>/xmb/<theme>/png [size]
#
# The loose files must stay: the tar is looked up first, the files are
# the fallback.

set -e

dir=${1%/}
size=${2:-64}

if [ ! -d "$dir" ]; then
   echo "usage: $0 <icons dir> [size]" >&2
   exit 1
fi

if command -v magick >/dev/null 2>&1; then
   im="magick"
else
   im="convert"
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for f in "$dir"/*.png; do
   $im "$f" -resize "${size}x${size}>" "PNG32:$tmp/$(basename "$f")"
done

tar --format=ustar -cf "$dir.tar" -C "$tmp" .
echo "$dir.tar: $(ls "$tmp" | wc -l) icons at up to ${size}px"
