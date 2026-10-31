#!/usr/bin/env bash
# =======================================================
# AlphaStocks Desktop Widget Launcher
# =======================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_EXEC="$(which python3)"

# 检查依赖
if ! $PYTHON_EXEC -c "import webview, AppKit, Quartz" 2>/dev/null; then
  echo "正在安装基础图形依赖 (pywebview, pyobjc)..."
  $PYTHON_EXEC -m pip install pywebview pyobjc-framework-Cocoa pyobjc-framework-Quartz -q
fi

# 检查是否已有进程在跑
EXISTING_PID=$(pgrep -f "app.py" | grep -v "$$" | head -n 1)
if [ -n "$EXISTING_PID" ]; then
  echo "AlphaStocks 小组件已在运行中 (PID: $EXISTING_PID)。"
  echo "若要重启，请执行: kill $EXISTING_PID"
  exit 0
fi

echo "🚀 启动 AlphaStocks Mac 桌面看盘小组件..."
nohup $PYTHON_EXEC "$DIR/app.py" > "$DIR/widget.log" 2>&1 &
PID=$!
echo "✅ AlphaStocks 已在桌面启动，PID: $PID"
echo "日志文件: $DIR/widget.log"
