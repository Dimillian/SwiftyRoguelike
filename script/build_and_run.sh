#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="SwiftyRoguelike"
PRODUCT_NAME="SwiftyRoguelike"
BUNDLE_ID="com.dimillian.SwiftyRoguelike.MVP"
MIN_SYSTEM_VERSION="26.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
APP_BUNDLE="$DIST_DIR/$APP_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"

cd "$ROOT_DIR"

if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
  pkill -x "$APP_NAME" || true
fi

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"

SDKROOT="$(xcrun --sdk macosx --show-sdk-path)"
TARGET_TRIPLE="$(uname -m)-apple-macosx$MIN_SYSTEM_VERSION"
SOURCE_FILES=()

while IFS= read -r source_file; do
  SOURCE_FILES+=("$source_file")
done < <(find "$ROOT_DIR/Sources/$PRODUCT_NAME" -name '*.swift' | sort)

swiftc \
  -swift-version 6 \
  -target "$TARGET_TRIPLE" \
  -sdk "$SDKROOT" \
  "${SOURCE_FILES[@]}" \
  -o "$APP_BINARY"

chmod +x "$APP_BINARY"
xattr -dr com.apple.quarantine "$APP_BUNDLE" 2>/dev/null || true

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSQuitAlwaysKeepsWindows</key>
  <false/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST

printf "APPL????" > "$APP_CONTENTS/PkgInfo"
xattr -dr com.apple.quarantine "$APP_BUNDLE" 2>/dev/null || true

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  run)
    open_app
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    echo "Streaming $APP_NAME process logs. Press Ctrl-C to stop."
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    echo "Streaming $APP_NAME telemetry. Press Ctrl-C to stop."
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\" || subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    echo "$APP_NAME launched"
    ;;
  *)
    echo "usage: $0 [run|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
