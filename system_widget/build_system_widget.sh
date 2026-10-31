#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_PATH="/Applications/AlphaStocks.app"
PLUGIN_PATH="$APP_PATH/Contents/PlugIns/AlphaStocksWidget.appex"

echo "=========================================="
echo "🔨 正在编译与安装 macOS 原生系统级小组件..."
echo "=========================================="

# 1. 编译 WidgetExtension (Mach-O)
echo "1/5 正在编译 WidgetKit Extension (arm64)..."
swiftc -target arm64-apple-macos14.0 -parse-as-library \
  -framework WidgetKit -framework SwiftUI -framework AppKit \
  "$DIR/MarketData.swift" "$DIR/Views.swift" "$DIR/AlphaStocksWidget.swift" \
  -o /tmp/AlphaStocksWidget_bin

# 2. 编译 Host App (Mach-O)
echo "2/5 正在编译 Host Application (arm64)..."
swiftc -target arm64-apple-macos14.0 \
  -framework SwiftUI -framework AppKit \
  "$DIR/MarketData.swift" "$DIR/MainApp.swift" \
  -o /tmp/AlphaStocks_bin

# 3. 组装 .app Bundle
echo "3/5 正在构建系统级 App 与 Extension 目录结构..."
rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$PLUGIN_PATH/Contents/MacOS"

# 拷贝二进制
cp /tmp/AlphaStocks_bin "$APP_PATH/Contents/MacOS/AlphaStocks"
chmod +x "$APP_PATH/Contents/MacOS/AlphaStocks"

cp /tmp/AlphaStocksWidget_bin "$PLUGIN_PATH/Contents/MacOS/AlphaStocksWidget"
chmod +x "$PLUGIN_PATH/Contents/MacOS/AlphaStocksWidget"

# 写入 Host App Info.plist
cat << 'EOF' > "$APP_PATH/Contents/Info.plist"
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
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# 写入 WidgetExtension Info.plist
cat << 'EOF' > "$PLUGIN_PATH/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>zh_CN</string>
    <key>CFBundleDisplayName</key>
    <string>AlphaStocks 看盘</string>
    <key>CFBundleExecutable</key>
    <string>AlphaStocksWidget</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.alphastocks.widget</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>AlphaStocksWidget</string>
    <key>CFBundlePackageType</key>
    <string>XPC!</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
EOF

# 4. 代码签名
echo "4/5 正在执行 macOS 本地代码签名..."
codesign -s - --force --deep "$PLUGIN_PATH"
codesign -s - --force --deep "$APP_PATH"

# 5. 系统级注册
echo "5/5 正在注册到 macOS LaunchServices 与 WidgetKit 子系统..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP_PATH"
pluginkit -a "$PLUGIN_PATH" 2>/dev/null || true
pluginkit -e use -i com.user.alphastocks.widget 2>/dev/null || true

# 刷新小组件守护进程
killall chronod 2>/dev/null || true

echo "=========================================="
echo "🎉 恭喜！原生系统级小组件已成功安装并注册！"
echo "=========================================="
