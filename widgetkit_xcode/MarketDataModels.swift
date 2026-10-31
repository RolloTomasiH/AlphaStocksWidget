//
//  MarketDataModels.swift
//  AlphaStocksWidget
//
//  Created for macOS Sonoma+ WidgetKit Desktop Widgets
//

import Foundation

public struct StockQuote: Identifiable, Codable {
    public var id: String { code }
    public let code: String
    public let name: String
    public let price: Double
    public let change: Double
    public let pct: Double
    public let high: Double
    public let low: Double
    public let turnover: String
    public let pe: Double
    public let sparkline: [Int]

    public var isPositive: Bool { pct >= 0 }
    public var posRatio: Double {
        guard high > low else { return 0.5 }
        return (price - low) / (high - low)
    }
}

public struct MacroIndex: Identifiable, Codable {
    public var id: String { key }
    public let key: String
    public let name: String
    public let price: String
    public let change: String
    public let pct: String
    public let rawPct: Double
}

public struct MarketBreadth: Codable {
    public let totalAmount: Double
    public let upCount: Int
    public let downCount: Int
    public let flatCount: Int

    public var upRatio: Double {
        let total = upCount + downCount + flatCount
        guard total > 0 else { return 0.5 }
        return Double(upCount) / Double(total)
    }
}

public struct MarketSnapshot: Codable {
    public let updateTime: String
    public let marketStatus: String
    public let macroIndices: [MacroIndex]
    public let breadth: MarketBreadth
    public let watchlist: [StockQuote]

    public static var sample: MarketSnapshot {
        MarketSnapshot(
            updateTime: "09:45",
            marketStatus: "A股盘中",
            macroIndices: [
                MacroIndex(key: "SH", name: "上证指数", price: "3,672.6", change: "+24.3", pct: "+0.67%", rawPct: 0.67),
                MacroIndex(key: "HSI", name: "恒生指数", price: "23,097.9", change: "+56.7", pct: "+0.25%", rawPct: 0.25),
                MacroIndex(key: "IXIC", name: "纳斯达克", price: "26,477.8", change: "+112.5", pct: "+0.43%", rawPct: 0.43),
                MacroIndex(key: "CNH", name: "美元/CNH", price: "6.6663", change: "+0.0016", pct: "+0.02%", rawPct: 0.02)
            ],
            breadth: MarketBreadth(totalAmount: 14219.0, upCount: 3120, downCount: 1750, flatCount: 210),
            watchlist: [
                StockQuote(code: "601899", name: "紫金矿业", price: 28.19, change: 0.34, pct: 1.22, high: 28.61, low: 27.98, turnover: "8.64亿", pe: 10.5, sparkline: [40, 50, 45, 60, 55, 70, 65, 80]),
                StockQuote(code: "688072", name: "拓荆科技", price: 465.96, change: 11.86, pct: 2.61, high: 467.20, low: 447.54, turnover: "6.35亿", pe: 62.6, sparkline: [30, 45, 50, 40, 65, 75, 70, 85]),
                StockQuote(code: "688981", name: "中芯国际", price: 101.35, change: 1.35, pct: 1.35, high: 102.50, low: 99.80, turnover: "21.4亿", pe: 120.4, sparkline: [50, 48, 55, 62, 58, 64, 70, 72]),
                StockQuote(code: "00700", name: "腾讯控股", price: 387.00, change: 1.80, pct: 0.47, high: 390.80, low: 384.00, turnover: "89.2亿", pe: 19.8, sparkline: [60, 55, 65, 58, 62, 60, 66, 68]),
                StockQuote(code: "NVDA", name: "英伟达", price: 188.50, change: 3.20, pct: 1.73, high: 190.20, low: 184.60, turnover: "$125亿", pe: 42.1, sparkline: [45, 52, 60, 58, 68, 72, 78, 82])
            ]
        )
    }
}
