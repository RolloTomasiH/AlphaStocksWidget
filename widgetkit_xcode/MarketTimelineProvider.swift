//
//  MarketTimelineProvider.swift
//  AlphaStocksWidget
//

import WidgetKit
import SwiftUI

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
        completion(MarketEntry(date: Date(), snapshot: .sample))
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<MarketEntry>) -> Void) {
        // 请求后台数据更新
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!

        // 使用 sample 或实际异步拉取结果
        let entry = MarketEntry(date: currentDate, snapshot: .sample)
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}
