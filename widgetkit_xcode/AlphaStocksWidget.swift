//
//  AlphaStocksWidget.swift
//  AlphaStocksWidget
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
    let kind: String = "AlphaStocksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MarketTimelineProvider()) { entry in
            AlphaStocksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("AlphaDesk 买方看盘")
        .description("展示全球大类资产天眼、市场情绪与自选股深度盘口")
        .supportedFamilies([.systemMedium, .systemLarge, .systemExtraLarge])
    }
}

struct AlphaStocksWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: MarketTimelineProvider.Entry

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(snapshot: entry.snapshot)
        case .systemLarge:
            LargeWidgetView(snapshot: entry.snapshot)
        default:
            LargeWidgetView(snapshot: entry.snapshot)
        }
    }
}
