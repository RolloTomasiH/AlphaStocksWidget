//
//  MainApp.swift
//  AlphaStocks Host Application
//

import SwiftUI
import AppKit

@main
struct AlphaStocksMainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 480, height: 380)
    }
}

struct ContentView: View {
    @State private var snapshot: MarketSnapshot = .sample

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Circle().fill(Color.green).frame(width: 8, height: 8)
                Text("AlphaStocks · 系统级看盘小组件")
                    .font(.headline)
                Spacer()
                Text("已安装至系统")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("💡 如何添加到 Mac 桌面：")
                    .font(.subheadline)
                    .fontWeight(.bold)

                Text("1. 在 Mac 桌面的任意空白处 **右键点击**，选择 **「编辑小组件 (Edit Widgets)」**。\n2. 在弹出的小组件库左侧列表中找到 **「AlphaStocks 看盘」**。\n3. 选择您喜欢的尺寸（Small / Medium / Large），直接拖放到桌面任意位置！\n4. 它将完全遵循 macOS 系统网格吸附，与其他小组件自动排列，绝不重叠！")
                    .font(.callout)
                    .lineSpacing(4)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)

            Spacer()

            HStack {
                Text("当前状态: 运行正常 · 自动跟随系统网格")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Button("关闭窗口") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(minWidth: 460, minHeight: 340)
    }
}
