//
//  AlphaStocksWidget.swift
//  AlphaStocks System Widget Entry
//

import WidgetKit
import SwiftUI

@main
struct AlphaStocksWidgetBundle: WidgetBundle {
    var body: some Widget {
        AlphaStocksWidget()
    }
}

struct AlphaStocksWidget: Widget {
    let kind: String = "com.user.alphastocks.widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarketTimelineProvider()) { entry in
            AlphaStocksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AlphaStocks 看盘")
        .description("买方全景桌面看盘小组件：大类资产天眼、两市温度计与深度多维盘口")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

public struct MarketEntry: TimelineEntry {
    public let date: Date
    public let snapshot: MarketSnapshot
}

public struct MarketTimelineProvider: TimelineProvider {
    public typealias Entry = MarketEntry

    public func placeholder(in context: Context) -> MarketEntry {
        MarketEntry(date: Date(), snapshot: .sample)
    }

    public func getSnapshot(in context: Context, completion: @escaping (MarketEntry) -> Void) {
        MarketFetcher.fetchSnapshot { snap in
            completion(MarketEntry(date: Date(), snapshot: snap))
        }
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<MarketEntry>) -> Void) {
        MarketFetcher.fetchSnapshot { snap in
            let currentDate = Date()
            // 设定 5 分钟后系统刷新
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate) ?? currentDate
            let entry = MarketEntry(date: currentDate, snapshot: snap)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct AlphaStocksWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: MarketTimelineProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(snapshot: entry.snapshot)
        case .systemMedium:
            MediumWidgetView(snapshot: entry.snapshot)
        case .systemLarge:
            LargeWidgetView(snapshot: entry.snapshot)
        default:
            LargeWidgetView(snapshot: entry.snapshot)
        }
    }
}
