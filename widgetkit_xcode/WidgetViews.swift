//
//  WidgetViews.swift
//  AlphaStocksWidget
//
//  Apple HIG / Liquid Glass Aesthetic for macOS Widgets
//

import SwiftUI
import WidgetKit

struct SparklineShape: Shape {
    let points: [Int]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard points.count > 1 else { return path }
        let step = rect.width / CGFloat(points.count - 1)

        let startY = rect.height - (CGFloat(points[0]) / 100.0 * rect.height)
        path.move(to: CGPoint(x: 0, y: startY))

        for (index, val) in points.enumerated().dropFirst() {
            let x = CGFloat(index) * step
            let y = rect.height - (CGFloat(val) / 100.0 * rect.height)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return path
    }
}

struct MediumWidgetView: View {
    let snapshot: MarketSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 6, height: 6)
                Text("AlphaDesk")
                    .font(.system(size: 11, weight: .semibold))
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
                        HStack(spacing: 2) {
                            Text(idx.price)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                            Text(idx.pct)
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(idx.rawPct >= 0 ? .red : .green)
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(6)
                }
            }

            // Watchlist Top 2
            VStack(spacing: 4) {
                ForEach(snapshot.watchlist.prefix(2)) { stock in
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(stock.name)
                                .font(.system(size: 11, weight: .semibold))
                            Text(stock.code)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 75, alignment: .leading)

                        SparklineShape(points: stock.sparkline)
                            .stroke(stock.isPositive ? Color.red : Color.green, lineWidth: 1.5)
                            .frame(width: 45, height: 16)

                        Spacer()

                        Text(String(format: "%.2f", stock.price))
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))

                        Text(String(format: "%+.2f%%", stock.pct))
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(stock.isPositive ? .red : .green)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background((stock.isPositive ? Color.red : Color.green).opacity(0.15))
                            .cornerRadius(4)
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding(12)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.85))
    }
}

struct LargeWidgetView: View {
    let snapshot: MarketSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                HStack(spacing: 5) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 7, height: 7)
                    Text("AlphaDesk 买方全景看板")
                        .font(.system(size: 12, weight: .bold))
                }
                Spacer()
                Text("\(snapshot.marketStatus) · \(snapshot.updateTime)")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }

            // Macro Grid (4 Key Indices)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                ForEach(snapshot.macroIndices.prefix(4)) { idx in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
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
                    .padding(6)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(8)
                }
            }

            // Market Breadth Bar
            VStack(spacing: 4) {
                HStack {
                    Text("两市情绪")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("成交: \(String(format: "%.0f", snapshot.breadth.totalAmount)) 亿")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
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
                .frame(height: 4)
            }

            // Watchlist (5 Rows)
            VStack(spacing: 6) {
                ForEach(snapshot.watchlist.prefix(4)) { stock in
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(stock.name)
                                .font(.system(size: 11, weight: .semibold))
                            Text(stock.code)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 70, alignment: .leading)

                        SparklineShape(points: stock.sparkline)
                            .stroke(stock.isPositive ? Color.red : Color.green, lineWidth: 1.5)
                            .frame(width: 48, height: 18)

                        // Range Bar
                        GeometryReader { g in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.12))
                                    .frame(height: 3)
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 7, height: 7)
                                    .offset(x: g.size.width * CGFloat(stock.posRatio) - 3.5)
                            }
                        }
                        .frame(height: 7)

                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.2f", stock.price))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                            Text(String(format: "%+.2f%%", stock.pct))
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(stock.isPositive ? .red : .green)
                        }
                        .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.vertical, 3)
                    .padding(.horizontal, 6)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(8)
                }
            }
        }
        .padding(14)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.85))
    }
}
