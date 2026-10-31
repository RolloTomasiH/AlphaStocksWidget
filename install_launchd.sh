#!/usr/bin/env bash
# =======================================================
# Install launchd service for AlphaStocks auto-start
# =======================================================

PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="$PLIST_DIR/com.user.alphastocks.plist"
SCRIPT_PATH="$HOME/AlphaStocksWidget/run.sh"

mkdir -p "$PLIST_DIR"

cat << EOF > "$PLIST_FILE"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.alphastocks</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
    <key>StandardOutPath</key>
    <string>$HOME/AlphaStocksWidget/launchd_stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/AlphaStocksWidget/launchd_stderr.log</string>
</dict>
</plist>
EOF

echo "✅ launchd 配置文件已生成: $PLIST_FILE"
echo "正在加载服务..."
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"
echo "🎉 AlphaStocks 开机自启动与桌面常驻已启用！"
