//
//  Colors.swift
//  StarLaunch
//
//  Created by Celal Can Sağnak on 10.10.2025.
//

import UIKit

enum Colors {

    // MARK: - Primary Colors
    static let appBackground = UIColor(hex: "#0A0F1C")
    static let cardBackground = UIColor(hex: "#111827")
    static let cardBackgroundLight = UIColor(hex: "#1F2937")

    // MARK: - Button Colors
    static let buttonBackground = UIColor(hex: "#1F2937")
    static let buttonBackgroundHighlight = UIColor(hex: "#374151")
    static let buttonPrimary = UIColor(hex: "#6366F1")
    static let buttonPrimaryHighlight = UIColor(hex: "#818CF8")

    // MARK: - Text Colors
    static let titleColor = UIColor(hex: "#F9FAFB")
    static let subtitleColor = UIColor(hex: "#9CA3AF")
    static let tertiaryColor = UIColor(hex: "#6B7280")

    // MARK: - Accent Colors
    static let accentBlue = UIColor(hex: "#3B82F6")
    static let accentPurple = UIColor(hex: "#8B5CF6")
    static let accentCyan = UIColor(hex: "#06B6D4")
    static let accentPink = UIColor(hex: "#EC4899")
    static let accentOrange = UIColor(hex: "#F97316")

    // MARK: - Status Colors
    static let success = UIColor(hex: "#10B981")
    static let warning = UIColor(hex: "#F59E0B")
    static let error = UIColor(hex: "#EF4444")
    static let info = UIColor(hex: "#3B82F6")

    // MARK: - Glassmorphism
    static let glassBackground = UIColor.white.withAlphaComponent(0.05)
    static let glassBorder = UIColor.white.withAlphaComponent(0.1)
    static let glassHighlight = UIColor.white.withAlphaComponent(0.15)

    // MARK: - Shadows
    static let shadowColor = UIColor.black.withAlphaComponent(0.3)
    static let glowBlue = UIColor(hex: "#3B82F6").withAlphaComponent(0.4)
    static let glowPurple = UIColor(hex: "#8B5CF6").withAlphaComponent(0.4)

    // MARK: - Gradients
    static var primaryGradient: [CGColor] {
        [UIColor(hex: "#6366F1").cgColor, UIColor(hex: "#8B5CF6").cgColor]
    }

    static var heroGradient: [CGColor] {
        [
            UIColor(hex: "#0A0F1C").cgColor, UIColor(hex: "#1E1B4B").cgColor,
            UIColor(hex: "#0A0F1C").cgColor,
        ]
    }

    static var cardGradient: [CGColor] {
        [UIColor(hex: "#1F2937").cgColor, UIColor(hex: "#111827").cgColor]
    }

    static var successGradient: [CGColor] {
        [UIColor(hex: "#10B981").cgColor, UIColor(hex: "#059669").cgColor]
    }

    static var blueGradient: [CGColor] {
        [UIColor(hex: "#3B82F6").cgColor, UIColor(hex: "#1D4ED8").cgColor]
    }

    static var purpleGradient: [CGColor] {
        [UIColor(hex: "#8B5CF6").cgColor, UIColor(hex: "#6D28D9").cgColor]
    }
}

// MARK: - UIColor Hex Extension
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }

    func lighter(by percentage: CGFloat = 0.2) -> UIColor {
        return adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 0.2) -> UIColor {
        return adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(
            red: min(max(red + percentage, 0), 1),
            green: min(max(green + percentage, 0), 1),
            blue: min(max(blue + percentage, 0), 1),
            alpha: alpha
        )
    }
}
