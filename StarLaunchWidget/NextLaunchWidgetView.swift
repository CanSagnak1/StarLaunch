//
//  NextLaunchWidgetView.swift
//  StarLaunchWidget
//
//  Created by Celal Can Sağnak on 7.01.2026.
//

import SwiftUI
import WidgetKit

// MARK: - Widget Views

/// Main widget view that adapts to different sizes
struct NextLaunchWidgetView: View {
    var entry: NextLaunchEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            CircularLockScreenView(entry: entry)
        case .accessoryRectangular:
            RectangularLockScreenView(entry: entry)
        case .accessoryInline:
            InlineLockScreenView(entry: entry)
        @unknown default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: NextLaunchEntry

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0A0F1C"), Color(hex: "1E1B4B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 4) {
                // Rocket icon and countdown
                HStack {
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "06B6D4"))

                    Spacer()

                    Text(entry.shortCountdownText)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "10B981"))
                }

                Spacer()

                // Launch name
                Text(entry.launchName)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                // Provider
                Text(entry.providerName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "9CA3AF"))
                    .lineLimit(1)
            }
            .padding(12)
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: NextLaunchEntry

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0A0F1C"), Color(hex: "1E1B4B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 16) {
                // Left side - Countdown
                VStack(alignment: .center, spacing: 4) {
                    Image(systemName: "rocket.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "06B6D4"))

                    Text(entry.countdownText)
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "10B981"))

                    Text("LAUNCH")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .frame(width: 100)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1)

                // Right side - Launch info
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.launchName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    HStack(spacing: 4) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "8B5CF6"))
                        Text(entry.providerName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "9CA3AF"))
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "F59E0B"))
                        Text(entry.locationName)
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(hex: "6B7280"))
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(entry.formattedLaunchDate)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "3B82F6"))
                }

                Spacer()
            }
            .padding(14)
        }
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let entry: NextLaunchEntry

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0A0F1C"), Color(hex: "1E1B4B"), Color(hex: "0A0F1C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("NEXT LAUNCH")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "06B6D4"))

                        Text("StarLaunch")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6B7280"))
                    }

                    Spacer()

                    Image(systemName: "rocket.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color(hex: "8B5CF6"))
                }

                // Countdown section
                VStack(spacing: 8) {
                    Text(entry.countdownText)
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "10B981"))

                    // Countdown boxes
                    if let components = entry.launchData?.countdownComponents {
                        HStack(spacing: 12) {
                            CountdownBox(value: components.days, label: "DAYS")
                            CountdownBox(value: components.hours, label: "HRS")
                            CountdownBox(value: components.minutes, label: "MIN")
                            CountdownBox(value: components.seconds, label: "SEC")
                        }
                    }
                }
                .padding(.vertical, 8)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 1)

                // Launch details
                VStack(alignment: .leading, spacing: 10) {
                    Text(entry.launchName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    LaunchInfoRow(
                        icon: "building.2.fill", iconColor: Color(hex: "8B5CF6"),
                        text: entry.providerName)
                    LaunchInfoRow(
                        icon: "location.fill", iconColor: Color(hex: "F59E0B"),
                        text: entry.locationName)
                    LaunchInfoRow(
                        icon: "calendar", iconColor: Color(hex: "3B82F6"),
                        text: entry.formattedLaunchDate)
                }

                Spacer()
            }
            .padding(16)
        }
    }
}

// MARK: - Lock Screen Widgets

struct CircularLockScreenView: View {
    let entry: NextLaunchEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 2) {
                Image(systemName: "rocket.fill")
                    .font(.system(size: 14))

                Text(entry.shortCountdownText)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .minimumScaleFactor(0.7)
            }
        }
    }
}

struct RectangularLockScreenView: View {
    let entry: NextLaunchEntry

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "rocket.fill")
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.launchName)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Text(entry.countdownText)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

struct InlineLockScreenView: View {
    let entry: NextLaunchEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "rocket.fill")
            Text("\(entry.providerName): \(entry.shortCountdownText)")
        }
    }
}

// MARK: - Helper Views

struct CountdownBox: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(String(format: "%02d", value))
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .frame(width: 50, height: 55)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct LaunchInfoRow: View {
    let icon: String
    let iconColor: Color
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(iconColor)
                .frame(width: 16)

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "9CA3AF"))
                .lineLimit(1)
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    StarLaunchWidget()
} timeline: {
    NextLaunchEntry.placeholder
}

#Preview("Medium", as: .systemMedium) {
    StarLaunchWidget()
} timeline: {
    NextLaunchEntry.placeholder
}
