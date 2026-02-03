import SwiftUI

struct CosmicColors {
    static let primary = Color(hex: "E8B4BC")
    static let secondary = Color(hex: "FFF5E6")
    static let accent = Color(hex: "C4A4C4")
    static let background = Color(hex: "FFFAF5")
    static let text = Color(hex: "4A4045")
    static let cosmicGold = Color(hex: "D4AF37")

    static let softRose = Color(hex: "E8B4BC")
    static let warmCream = Color(hex: "FFF5E6")
    static let dustyLavender = Color(hex: "C4A4C4")
    static let offWhite = Color(hex: "FFFAF5")
    static let warmCharcoal = Color(hex: "4A4045")
    static let softGold = Color(hex: "D4AF37")

    static let excellent = Color(hex: "7CB342")
    static let good = Color(hex: "9CCC65")
    static let neutral = Color(hex: "FFB74D")
    static let challenging = Color(hex: "FF8A65")
    static let difficult = Color(hex: "E57373")

    static let fire = Color(hex: "FF7043")
    static let earth = Color(hex: "8D6E63")
    static let air = Color(hex: "4FC3F7")
    static let water = Color(hex: "5C6BC0")

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

    static func scoreColor(for score: Double) -> Color {
        switch score {
        case 8.5...10: return excellent
        case 7...8.49: return good
        case 5...6.99: return neutral
        case 3...4.99: return challenging
        default: return difficult
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
