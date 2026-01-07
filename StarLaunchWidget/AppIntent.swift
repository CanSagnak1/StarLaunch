//
//  AppIntent.swift
//  StarLaunchWidget
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import AppIntents
import WidgetKit

/// Configuration intent for the widget
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Next Launch Widget"
    static var description = IntentDescription("Shows the next upcoming rocket launch")

    @Parameter(title: "Show Provider", default: true)
    var showProvider: Bool

    @Parameter(title: "Show Location", default: true)
    var showLocation: Bool
}
