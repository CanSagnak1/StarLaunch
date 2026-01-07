//
//  StarLaunchWidget.swift
//  StarLaunchWidget
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import SwiftUI
import WidgetKit

/// Main widget configuration
struct StarLaunchWidget: Widget {
    let kind: String = "StarLaunchWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: NextLaunchProvider()
        ) { entry in
            NextLaunchWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: "0A0F1C")
                }
        }
        .configurationDisplayName("Next Launch")
        .description("Countdown to the next rocket launch")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
