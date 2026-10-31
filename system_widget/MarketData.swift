//
//  MarketData.swift
//  AlphaStocks System Widget
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
        return min(max((price - low) / (high - low), 0.0), 1.0)
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
            updateTime: "10:05",
            marketStatus: "A股盘中交易",
            macroIndices: [
                MacroIndex(key: "SH", name: "上证指数", price: "3,673.5", change: "+25.2", pct: "+0.69%", rawPct: 0.69),
                MacroIndex(key: "SZ", name: "深证成指", price: "11,425.8", change: "+179.9", pct: "+1.60%", rawPct: 1.60),
                MacroIndex(key: "HSI", name: "恒生指数", price: "23,097.9", change: "+56.7", pct: "+0.25%", rawPct: 0.25),
                MacroIndex(key: "IXIC", name: "纳斯达克", price: "26,477.8", change: "+112.5", pct: "+0.43%", rawPct: 0.43)
            ],
            breadth: MarketBreadth(totalAmount: 4140.9, upCount: 3120, downCount: 1750, flatCount: 210),
            watchlist: [
                StockQuote(code: "601899", name: "紫金矿业", price: 28.06, change: 0.21, pct: 0.75, high: 28.61, low: 27.98, turnover: "8.6亿", pe: 10.5, sparkline: [40, 48, 45, 58, 52, 65, 60, 72, 70]),
                StockQuote(code: "688072", name: "拓荆科技", price: 467.31, change: 13.21, pct: 2.91, high: 475.00, low: 447.54, turnover: "6.8亿", pe: 62.6, sparkline: [30, 42, 55, 50, 68, 75, 70, 85, 82]),
                StockQuote(code: "688981", name: "中芯国际", price: 101.82, change: 1.82, pct: 1.82, high: 103.50, low: 100.40, turnover: "22.5亿", pe: 121.0, sparkline: [50, 52, 58, 64, 60, 66, 72, 70, 75]),
                StockQuote(code: "00700", name: "腾讯控股", price: 387.40, change: 2.20, pct: 0.57, high: 390.80, low: 384.00, turnover: "89.2亿", pe: 19.8, sparkline: [58, 54, 62, 59, 64, 61, 65, 66, 68]),
                StockQuote(code: "NVDA", name: "英伟达", price: 188.50, change: 3.20, pct: 1.73, high: 190.20, low: 184.60, turnover: "$125亿", pe: 42.1, sparkline: [45, 50, 58, 56, 65, 70, 76, 80, 82])
            ]
        )
    }
}

public class MarketFetcher {
    public static func fetchSnapshot(completion: @escaping (MarketSnapshot) -> Void) {
        let symbols = "s_sh000001,s_sz399001,s_r_hkHSI,us.IXIC,sh601899,sh688072,sh688981,r_hk00700,usNVDA.O"
        guard let url = URL(string: "https://qt.gtimg.cn/q=\(symbols)") else {
            completion(.sample)
            return
        }

        var req = URLRequest(url: url)
        req.timeoutInterval = 4
        URLSession.shared.dataTask(with: req) { data, _, err in
            guard let data = data else {
                completion(.sample)
                return
            }

            let gbkEncoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
            let content = String(data: data, encoding: .utf8) ?? String(data: data, encoding: gbkEncoding) ?? ""

            var macroList: [MacroIndex] = []
            var stockList: [StockQuote] = []
            var totalAmount: Double = 4140.0

            let lines = content.components(separatedBy: ";")
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                let parts = trimmed.components(separatedBy: "~")

                if trimmed.contains("s_sh000001") && parts.count > 5 {
                    let price = parts[3]
                    let chg = parts[4]
                    let pct = parts[5]
                    let rawPct = Double(pct) ?? 0.0
                    macroList.append(MacroIndex(key: "SH", name: "上证指数", price: price, change: chg, pct: "\(pct)%", rawPct: rawPct))
                    if parts.count > 7, let vol = Double(parts[7]) { totalAmount = vol / 10000.0 }
                } else if trimmed.contains("s_sz399001") && parts.count > 5 {
                    let price = parts[3]
                    let chg = parts[4]
                    let pct = parts[5]
                    let rawPct = Double(pct) ?? 0.0
                    macroList.append(MacroIndex(key: "SZ", name: "深证成指", price: price, change: chg, pct: "\(pct)%", rawPct: rawPct))
                } else if trimmed.contains("s_r_hkHSI") && parts.count > 5 {
                    let price = parts[3]
                    let chg = parts[4]
                    let pct = parts[5]
                    let rawPct = Double(pct) ?? 0.0
                    macroList.append(MacroIndex(key: "HSI", name: "恒生指数", price: price, change: chg, pct: "\(pct)%", rawPct: rawPct))
                } else if trimmed.contains("us.IXIC") && parts.count > 5 {
                    let price = parts[3]
                    let chg = parts[4]
                    let pct = parts[5]
                    let rawPct = Double(pct) ?? 0.0
                    macroList.append(MacroIndex(key: "IXIC", name: "纳斯达克", price: price, change: chg, pct: "\(pct)%", rawPct: rawPct))
                } else if parts.count > 34 {
                    // 个股
                    let name = parts[1]
                    let code = parts[2]
                    let price = Double(parts[3]) ?? 0.0
                    let chg = Double(parts[31]) ?? 0.0
                    let pct = Double(parts[32]) ?? 0.0
                    let high = Double(parts[33]) ?? price
                    let low = Double(parts[34]) ?? price
                    let turnoverRaw = Double(parts[37]) ?? 0.0
                    let pe = Double(parts.count > 39 ? parts[39] : "0") ?? 0.0

                    let turnoverStr = turnoverRaw > 10000 ? String(format: "%.1f亿", turnoverRaw / 10000.0) : String(format: "%.0f万", turnoverRaw)

                    stockList.append(StockQuote(
                        code: code,
                        name: name,
                        price: price,
                        change: chg,
                        pct: pct,
                        high: high,
                        low: low,
                        turnover: turnoverStr,
                        pe: pe,
                        sparkline: [40, 45, 50, 48, 60, 65, 70, 75, 72]
                    ))
                }
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let timeStr = formatter.string(from: Date())

            if macroList.isEmpty {
                completion(.sample)
            } else {
                let snap = MarketSnapshot(
                    updateTime: timeStr,
                    marketStatus: "A股盘中交易",
                    macroIndices: macroList,
                    breadth: MarketBreadth(totalAmount: totalAmount, upCount: 3120, downCount: 1750, flatCount: 210),
                    watchlist: stockList.isEmpty ? MarketSnapshot.sample.watchlist : stockList
                )
                completion(snap)
            }
        }.resume()
    }
}
