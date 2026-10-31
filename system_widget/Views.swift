//
//  Views.swift
//  AlphaStocks System Widget Views
//

import SwiftUI
import WidgetKit

struct SparklinePath: Shape {
    let points: [Int]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        let step = rect.width / CGFloat(points.count - 1)
        let startY = rect.height - (CGFloat(points[0]) / 100.0 * rect.height)
        path.move(to: CGPoint(x: 0, y: startY))

        for (i, p) in points.enumerated().dropFirst() {
            let x = CGFloat(i) * step
            let y = rect.height - (CGFloat(p) / 100.0 * rect.height)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

// 1. Small 规格 (单标的深度盯盘)
struct SmallWidgetView: View {
    let snapshot: MarketSnapshot

    var stock: StockQuote {
        snapshot.watchlist.first ?? MarketSnapshot.sample.watchlist[0]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(stock.name)
                        .font(.system(size: 13, weight: .bold))
                    Text(stock.code)
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(String(format: "%+.2f%%", stock.pct))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(stock.isPositive ? .red : .green)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background((stock.isPositive ? Color.red : Color.green).opacity(0.16))
                    .cornerRadius(5)
            }

            Text(String(format: "%.2f", stock.price))
                .font(.system(size: 20, weight: .bold, design: .monospaced))

            SparklinePath(points: stock.sparkline)
                .stroke(stock.isPositive ? Color.red : Color.green, lineWidth: 1.6)
                .frame(height: 28)

            // Range Slider
            VStack(spacing: 2) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.12)).frame(height: 3)
                        Circle().fill(Color.white).frame(width: 7, height: 7)
                            .offset(x: geo.size.width * CGFloat(stock.posRatio) - 3.5)
                    }
                }
                .frame(height: 7)

                HStack {
                    Text(String(format: "%.2f", stock.low)).font(.system(size: 8, design: .monospaced)).foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.2f", stock.high)).font(.system(size: 8, design: .monospaced)).foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(NSColor.windowBackgroundColor)
        }
    }
}

// 2. Medium 规格 (指数天眼 + Top 2 股票)
struct MediumWidgetView: View {
    let snapshot: MarketSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Circle().fill(Color.green).frame(width: 6, height: 6)
                Text("AlphaStocks")
                    .font(.system(size: 11, weight: .bold))
                Spacer()
                Text("\(snapshot.marketStatus) · \(snapshot.updateTime)")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            // Macro Pills
            HStack(spacing: 6) {
                ForEach(snapshot.macroIndices.prefix(3)) { idx in
                    VStack(alignment: .leading, spacing: 1) {
                        Text(idx.name)
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                        HStack(spacing: 3) {
                            Text(idx.price)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                            Text(idx.pct)
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(idx.rawPct >= 0 ? .red : .green)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(6)
                }
            }

            // Top 2 Stocks
            VStack(spacing: 4) {
                ForEach(snapshot.watchlist.prefix(2)) { s in
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(s.name)
                                .font(.system(size: 11, weight: .semibold))
                            Text(s.code)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 75, alignment: .leading)

                        SparklinePath(points: s.sparkline)
                            .stroke(s.isPositive ? Color.red : Color.green, lineWidth: 1.5)
                            .frame(width: 50, height: 16)

                        Spacer()

                        Text(String(format: "%.2f", s.price))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))

                        Text(String(format: "%+.2f%%", s.pct))
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(s.isPositive ? .red : .green)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background((s.isPositive ? Color.red : Color.green).opacity(0.15))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(NSColor.windowBackgroundColor)
        }
    }
}

// 3. Large 规格 (买方全景大板)
struct LargeWidgetView: View {
    let snapshot: MarketSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            // Header
            HStack {
                HStack(spacing: 5) {
                    Circle().fill(Color.green).frame(width: 7, height: 7)
                    Text("AlphaStocks 买方看板")
                        .font(.system(size: 12, weight: .bold))
                }
                Spacer()
                Text("\(snapshot.marketStatus) · \(snapshot.updateTime)")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            // Macro Grid (4 指数)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
                ForEach(snapshot.macroIndices.prefix(4)) { idx in
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(idx.name)
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                            Text(idx.price)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                        Spacer()
                        Text(idx.pct)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(idx.rawPct >= 0 ? .red : .green)
                    }
                    .padding(5)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(7)
                }
            }

            // 情绪温度计
            VStack(spacing: 3) {
                HStack {
                    Text("两市成交: \(String(format: "%.0f", snapshot.breadth.totalAmount)) 亿元")
                        .font(.system(size: 9, weight: .medium))
                    Spacer()
                    Text("涨 \(snapshot.breadth.upCount) / 跌 \(snapshot.breadth.downCount)")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: geo.size.width * CGFloat(snapshot.breadth.upRatio))
                        Rectangle()
                            .fill(Color.green)
                    }
                    .cornerRadius(2)
                }
                .frame(height: 3)
            }

            // 自选股列表 (4 行)
            VStack(spacing: 5) {
                ForEach(snapshot.watchlist.prefix(4)) { s in
                    HStack(spacing: 6) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(s.name)
                                .font(.system(size: 11, weight: .semibold))
                            Text(s.code)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 68, alignment: .leading)

                        SparklinePath(points: s.sparkline)
                            .stroke(s.isPositive ? Color.red : Color.green, lineWidth: 1.4)
                            .frame(width: 44, height: 16)

                        // Range Slider
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color.white.opacity(0.12)).frame(height: 3)
                                Circle().fill(Color.white).frame(width: 6, height: 6)
                                    .offset(x: g.size.width * CGFloat(s.posRatio) - 3)
                            }
                        }
                        .frame(height: 6)

                        VStack(alignment: .trailing, spacing: 1) {
                            Text(String(format: "%.2f", s.price))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                            Text(String(format: "%+.2f%%", s.pct))
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(s.isPositive ? .red : .green)
                        }
                        .frame(width: 58, alignment: .trailing)
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(7)
                }
            }
        }
        .padding(13)
        .containerBackground(for: .widget) {
            Color(NSColor.windowBackgroundColor)
        }
    }
}
