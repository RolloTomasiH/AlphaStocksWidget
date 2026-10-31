# AlphaStocks macOS Desktop & System Widget

[![macOS](https://img.shields.io/badge/macOS-12.0+-black?logo=apple&logoColor=white)](https://apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343?logo=swift&logoColor=white)](https://swift.org)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?logo=python&logoColor=white)](https://python.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**AlphaStocks** is a high-performance, native macOS desktop market tracking widget for active traders, quants, and investors. It provides real-time quotes, breadth indicators, and watchlist tracking across **A-Shares, HK Stocks, US Stocks, FX, and Commodities**.

AlphaStocks provides two flexible display modes:
1. **Desktop Floating Widget**: A frosted-glass floating or pinned-to-desktop widget powered by PyObjC and PyWebView.
2. **Native Apple WidgetKit Extension**: Written in pure Swift / SwiftUI that integrates seamlessly into macOS Sonoma & Sequoia Desktop and Notification Center.

---

## ✨ Features

- 📈 **Multi-Market Coverage**: Real-time quotes for China A-shares (SH/SZ/BJ), Hong Kong equities (HKEX), US stocks (NASDAQ/NYSE), Forex, and Commodities.
- 🪟 **Dual Widget Architecture**:
  - **Desktop Floating Window**: Native Quartz / AppKit integration allowing the widget to sit permanently beneath desktop icons (`kCGDesktopWindowLevel`) or float always-on-top.
  - **Apple System WidgetKit**: Native Swift / SwiftUI widget extension compiling directly with `swiftc` or Xcode.
- 🎨 **Apple Design Aesthetics**: Liquid Glass materials, dark mode, high-density financial typography, and customizable color schemes (China red-up/green-down vs Western green-up/red-down).
- 📐 **Multiple Layout Sizes**: Medium (compact banner), Large (standard watchlist), and Extra Large (full multi-market board).
- ⚡ **Zero Bloat & Low Overhead**: Pure lightweight HTTP polling engine without heavyweight browser background processes or electron runtimes.

---

## 🚀 Quick Start (Desktop Widget)

### Prerequisites

- macOS 12.0 or higher
- Python 3.9+ with pip

### Installation & Run

```bash
# Clone the repository
git clone https://github.com/RolloTomasiH/AlphaStocksWidget.git
cd AlphaStocksWidget

# Run directly (installs pywebview and pyobjc dependencies automatically)
chmod +x run.sh
./run.sh
```

### Build as a Native `.app` Bundle

```bash
chmod +x make_app.sh
./make_app.sh

# The generated AlphaStocks.app is ready in the project directory
open AlphaStocks.app
```

### Install Auto-Start at Boot (launchd)

```bash
chmod +x install_launchd.sh
./install_launchd.sh
```

---

## 🛠️ Native Apple WidgetKit Extension (macOS 14+)

To compile and install the native Swift WidgetKit extension directly to `/Applications/AlphaStocks.app`:

```bash
cd system_widget
chmod +x build_system_widget.sh
./build_system_widget.sh
```

Once installed:
1. Right click on your macOS Desktop and select **Edit Widgets...**
2. Find **AlphaStocks** in the widget browser.
3. Drag your desired size (Medium / Large) onto your Desktop or Notification Center.

---

## ⚙️ Configuration

Configuration is automatically stored in `~/.config/alphastocks/config.json`:

```json
{
  "size": "large",
  "window_level": "desktop",
  "color_scheme": "china",
  "refresh_interval": 5,
  "watchlist": [
    {"code": "601899", "market": "sh", "name": "紫金矿业"},
    {"code": "688072", "market": "sh", "name": "拓荆科技"},
    {"code": "688981", "market": "sh", "name": "中芯国际"},
    {"code": "00700", "market": "hk", "name": "腾讯控股"},
    {"code": "NVDA", "market": "us", "name": "英伟达"},
    {"code": "MRVL", "market": "us", "name": "迈威尔科技"},
    {"code": "AMAT", "market": "us", "name": "应用材料"}
  ]
}
```

---

## 📄 License

[MIT License](LICENSE) © 2026 Rollo Tomasi
