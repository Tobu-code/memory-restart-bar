#!/usr/bin/env bash
set -euo pipefail

APP_NAME="MemoryRestartBar"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist"
APP_DIR="${DIST_DIR}/${APP_NAME}.app"
BIN_PATH="${ROOT_DIR}/.build/release/${APP_NAME}"
PLIST_PATH="${APP_DIR}/Contents/Info.plist"
ICONSET_DIR="${ROOT_DIR}/Assets/AppIcon.iconset"
ICNS_PATH="${ROOT_DIR}/Assets/AppIcon.icns"

echo "[1/4] Building release binary..."
swift build -c release --package-path "${ROOT_DIR}"

if [[ ! -x "${BIN_PATH}" ]]; then
  echo "Build output missing: ${BIN_PATH}" >&2
  exit 1
fi

echo "[2/4] Creating app bundle..."
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS" "${APP_DIR}/Contents/Resources"
cp "${BIN_PATH}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"
chmod +x "${APP_DIR}/Contents/MacOS/${APP_NAME}"

if [[ ! -f "${ICNS_PATH}" ]]; then
  if [[ -d "${ICONSET_DIR}" ]]; then
    iconutil -c icns "${ICONSET_DIR}" -o "${ICNS_PATH}"
  else
    echo "Warning: icon not found, app will use default icon."
  fi
fi

if [[ -f "${ICNS_PATH}" ]]; then
  cp "${ICNS_PATH}" "${APP_DIR}/Contents/Resources/AppIcon.icns"
fi

cat > "${PLIST_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>local.memoryrestartbar.app</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
EOF

echo "[3/4] Ad-hoc signing..."
codesign --force --deep --sign - "${APP_DIR}"

echo "[4/4] Done."
echo "App bundle: ${APP_DIR}"
