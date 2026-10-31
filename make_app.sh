#!/usr/bin/env bash
# =======================================================
# Build Native macOS Application Bundle (AlphaStocks.app)
# =======================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="AlphaStocks.app"
APP_DIR="$DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "📦 正在构建 macOS 原生应用包: $APP_DIR ..."

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# 1. 编写 Info.plist
cat << 'EOF' > "$CONTENTS_DIR/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleExecutable</key>
    <string>AlphaStocks</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.alphastocks</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>AlphaStocks</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 2. 编写 MacOS 执行脚本
cat << 'EOF' > "$MACOS_DIR/AlphaStocks"
#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
PYTHON_CMD="$(which python3 || echo /usr/bin/python3)"
exec "$PYTHON_CMD" "$DIR/app.py"
EOF

chmod +x "$MACOS_DIR/AlphaStocks"

echo "✅ 构建完成！应用位于: $APP_DIR"
echo "你可以双击运行，或执行: cp -r \"$APP_DIR\" /Applications/"
