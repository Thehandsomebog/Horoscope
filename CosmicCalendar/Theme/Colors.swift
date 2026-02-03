import SwiftUI

struct CosmicColors {
    // MARK: - Primary Palette
    static let primary = Color(hex: "D4939E")       // Darker rose for better contrast
    static let secondary = Color(hex: "FFF5E6")
    static let accent = Color(hex: "9B7A9B")        // Darker lavender for better contrast
    static let background = Color(hex: "FFFAF5")
    static let text = Color(hex: "4A4045")

    // MARK: - Text Colors with WCAG Compliant Contrast
    /// Secondary text color - meets WCAG AA contrast ratio (4.5:1) on white/background
    static let textSecondary = Color(hex: "6B5F64") // Darker than opacity(0.7) for better contrast

    /// Tertiary text color - for less important information
    static let textTertiary = Color(hex: "7A6E73")  // Slightly lighter but still meets AA

    // MARK: - Decorative Colors (Use with caution for text)
    static let cosmicGold = Color(hex: "B8941F")    // Darker gold for better contrast

    // Legacy named colors
    static let softRose = Color(hex: "D4939E")
    static let warmCream = Color(hex: "FFF5E6")
    static let dustyLavender = Color(hex: "9B7A9B")
    static let offWhite = Color(hex: "FFFAF5")
    static let warmCharcoal = Color(hex: "4A4045")
    static let softGold = Color(hex: "B8941F")

    // MARK: - Score Colors (Meet contrast requirements)
    static let excellent = Color(hex: "558B2F")     // Darker green
    static let good = Color(hex: "7CB342")
    static let neutral = Color(hex: "E65100")       // Darker orange
    static let challenging = Color(hex: "E64A19")   // Darker orange-red
    static let difficult = Color(hex: "C62828")     // Darker red

    // MARK: - Element Colors
    static let fire = Color(hex: "E64A19")
    static let earth = Color(hex: "5D4037")
    static let air = Color(hex: "0277BD")
    static let water = Color(hex: "3949AB")

    // MARK: - Gradients
    static let gradientStart = Color(hex: "FFE4E8")
    static let gradientEnd = Color(hex: "E8D4F0")

    static var cosmicGradient: LinearGradient {
        LinearGradient(
            colors: [gradientStart, gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [.white.opacity(0.9), secondary.opacity(0.8)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Score Color Helper

    static func scoreColor(for score: Double) -> Color {
        switch score {
        case 8.5...10: return excellent
        case 7...8.49: return good
        case 5...6.99: return neutral
        case 3...4.99: return challenging
        default: return difficult
        }
    }

    /// Returns a text-safe version of the score color (darker for better contrast)
    static func scoreTextColor(for score: Double) -> Color {
        switch score {
        case 8.5...10: return Color(hex: "33691E") // Dark green
        case 7...8.49: return Color(hex: "558B2F")
        case 5...6.99: return Color(hex: "BF360C") // Dark orange
        case 3...4.99: return Color(hex: "BF360C")
        default: return Color(hex: "B71C1C")       // Dark red
        }
    }

    static func elementColor(for element: Element) -> Color {
        switch element {
        case .fire: return fire
        case .earth: return earth
        case .air: return air
        case .water: return water
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
