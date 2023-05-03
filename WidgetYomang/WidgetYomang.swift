//
//  WidgetYomang.swift
//  WidgetYomang
//
//  Created by 제나 on 2023/05/02.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

extension UserDefaults {
    static var shared: UserDefaults {
        let appGroupID = "group.Demo0404"
        return UserDefaults(suiteName: appGroupID)!
    }
}

struct WidgetYomangEntryView : View {
    var entry: Provider.Entry
    let nameUserDefaults = UserDefaults(suiteName: "group.Demo0404")
    
    var body: some View {
        if let widgetImageData = nameUserDefaults?.data(forKey: "widgetImage"),
           let widgetImage = UIImage(data: widgetImageData) {
            
            Image(uiImage: widgetImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct WidgetYomang: Widget {
    
    let kind: String = "WidgetYomang"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetYomangEntryView(entry: entry)
        }
        .configurationDisplayName("YOMANG")
        .description("요망이 테스트입니다")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct WidgetYomang_Previews: PreviewProvider {
    static var previews: some View {
        WidgetYomangEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
