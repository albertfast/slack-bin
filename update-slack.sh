#!/bin/bash
set -e

echo "🔍 Fetching actual Slack RPM URL from Slack page..."

TMPFILE=$(mktemp)
wget -qO "$TMPFILE" "https://slack.com/downloads/instructions/linux?ddl=1&build=rpm"

RPM_URL=$(grep -oE 'https://downloads\.slack-edge\.com[^"]+\.rpm' "$TMPFILE" | head -n1)
rm "$TMPFILE"

if [[ -z "$RPM_URL" ]]; then
  echo "❌ Failed to find .rpm download URL from Slack page!"
  exit 1
fi

FILENAME=$(basename "$RPM_URL")
VERSION=$(echo "$FILENAME" | grep -oP '(?<=slack-)[0-9]+\.[0-9]+\.[0-9]+')

echo "📦 Download URL: $RPM_URL"
echo "📦 Filename: $FILENAME"
echo "🔧 Version: $VERSION"

# Güncelle PKGBUILD
sed -i "s/^pkgver=.*/pkgver=$VERSION/" PKGBUILD
sed -i "s|^source=.*|source=(\"$RPM_URL\")|" PKGBUILD

echo "📥 Downloading RPM..."
wget -O "$FILENAME" "$RPM_URL"

echo "📄 Regenerating .SRCINFO..."
makepkg --printsrcinfo > .SRCINFO

echo "✅ Done. You can now run: makepkg -si"
