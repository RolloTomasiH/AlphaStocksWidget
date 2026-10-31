# AlphaStocks WidgetKit 原生项目说明 (macOS Sonoma+)

本目录包含完整的 Apple WidgetKit 原生小组件源码，适配 macOS 14+ 桌面小组件体系。

## 文件结构
- `AlphaStocksWidget.swift`: 小组件入口与 Bundle 定义，支持 `systemMedium` 与 `systemLarge`
- `MarketDataModels.swift`: 强类型数据模型（指数、自选股、分时走势、市场情绪）
- `WidgetViews.swift`: SwiftUI 原生渲染，复刻 Liquid Glass 磨砂质感与 Sparkline
- `MarketTimelineProvider.swift`: 系统 Timeline 驱动调度器

## 在 Xcode 中集成
1. 打开 Xcode -> File -> New -> Project -> macOS -> App。
2. 添加 Target -> Widget Extension -> 命名为 `AlphaStocksWidget`。
3. 将本目录下的 4 个 `.swift` 文件拖入该 Target。
4. 在 Xcode 中点击 Run，即可在 macOS 桌面右键「编辑小组件」里找到 **AlphaDesk 买方看盘**，直接拖到桌面任意位置！
