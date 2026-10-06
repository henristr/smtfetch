#!/usr/bin/env bash

set -e

REPO="henristr/smtfetch"
BINARY="smtfetch"
INSTALL_DIR="/usr/local/bin"

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        GOARCH="x86_64"
        ;;
    aarch64|arm64)
        GOARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

URL="https://github.com/$REPO/releases/latest/download/${BINARY}_Linux_${GOARCH}.tar.gz"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading latest smtfetch..."

curl -fL "$URL" -o "$TMP_DIR/$BINARY.tar.gz"

tar -xzf "$TMP_DIR/$BINARY.tar.gz" -C "$TMP_DIR"

sudo install -m 755 "$TMP_DIR/$BINARY" "$INSTALL_DIR/$BINARY"

echo
echo "smtfetch successfully installed!"
echo

"$INSTALL_DIR/$BINARY"