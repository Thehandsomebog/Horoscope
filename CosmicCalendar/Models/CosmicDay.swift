import Foundation

struct CosmicDay: Identifiable, Equatable {
    let id: Date
    let date: Date
    let overallScore: Double
    let relationshipScore: Double
    let careerScore: Double
    let healthScore: Double
    let moonPhase: MoonPhase
    let planetaryPositions: [PlanetaryPosition]
    let activeRetrogrades: [Planet]
    let significantAspects: [PlanetaryAspect]
    let recommendations: [Recommendation]

    var scoreCategory: ScoreCategory {
        ScoreCategory.from(score: overallScore)
    }

    static func == (lhs: CosmicDay, rhs: CosmicDay) -> Bool {
        lhs.id == rhs.id
    }
}

enum ScoreCategory: String {
    case excellent = "Excellent"
    case good = "Good"
    case neutral = "Neutral"
    case challenging = "Challenging"
    case difficult = "Difficult"

    static func from(score: Double) -> ScoreCategory {
        switch score {
        case 8.5...10: return .excellent
        case 7...8.49: return .good
        case 5...6.99: return .neutral
        case 3...4.99: return .challenging
        default: return .difficult
        }
    }

    var description: String {
        switch self {
        case .excellent: return "The cosmos are strongly aligned in your favor"
        case .good: return "Favorable energies support your endeavors"
        case .neutral: return "A balanced day with mixed influences"
        case .challenging: return "Navigate with extra awareness today"
        case .difficult: return "Practice patience and self-care"
        }
    }

    var emoji: String {
        switch self {
        case .excellent: return "✨"
        case .good: return "🌟"
        case .neutral: return "🌙"
        case .challenging: return "🌊"
        case .difficult: return "🌑"
        }
    }
}

enum MoonPhase: String, Codable, CaseIterable {
    case newMoon = "New Moon"
    case waxingCrescent = "Waxing Crescent"
    case firstQuarter = "First Quarter"
    case waxingGibbous = "Waxing Gibbous"
    case fullMoon = "Full Moon"
    case waningGibbous = "Waning Gibbous"
    case lastQuarter = "Last Quarter"
    case waningCrescent = "Waning Crescent"

    var symbol: String {
        switch self {
        case .newMoon: return "🌑"
        case .waxingCrescent: return "🌒"
        case .firstQuarter: return "🌓"
        case .waxingGibbous: return "🌔"
        case .fullMoon: return "🌕"
        case .waningGibbous: return "🌖"
        case .lastQuarter: return "🌗"
        case .waningCrescent: return "🌘"
        }
    }

    var scoreModifier: Double {
        switch self {
        case .fullMoon: return 1.0
        case .newMoon: return 0.5
        case .waxingGibbous, .waxingCrescent: return 0.25
        case .firstQuarter, .lastQuarter: return 0.0
        case .waningGibbous, .waningCrescent: return -0.5
        }
    }

    var description: String {
        switch self {
        case .newMoon:
            return "Time for new beginnings and setting intentions. Plant seeds for future growth."
        case .waxingCrescent:
            return "Building momentum. Take initial steps toward your goals."
        case .firstQuarter:
            return "Decision time. Overcome obstacles and commit to your path."
        case .waxingGibbous:
            return "Refine and adjust. Make final preparations before culmination."
        case .fullMoon:
            return "Peak energy and illumination. Celebrate achievements and gain clarity."
        case .waningGibbous:
            return "Share wisdom and gratitude. Distribute what you've gained."
        case .lastQuarter:
            return "Release and let go. Clear what no longer serves you."
        case .waningCrescent:
            return "Rest and reflect. Prepare for the next cycle."
        }
    }

    var activities: [String] {
        switch self {
        case .newMoon:
            return ["Set intentions", "Start new projects", "Meditation", "Journaling"]
        case .waxingCrescent:
            return ["Take action", "Build momentum", "Network", "Learn new skills"]
        case .firstQuarter:
            return ["Make decisions", "Face challenges", "Adjust plans", "Stay focused"]
        case .waxingGibbous:
            return ["Refine details", "Prepare presentations", "Final edits", "Self-improvement"]
        case .fullMoon:
            return ["Celebrate wins", "Social gatherings", "Creative expression", "Manifestation rituals"]
        case .waningGibbous:
            return ["Share knowledge", "Express gratitude", "Mentor others", "Give back"]
        case .lastQuarter:
            return ["Declutter", "End unhealthy patterns", "Forgiveness work", "Clean spaces"]
        case .waningCrescent:
            return ["Rest deeply", "Dream work", "Spiritual practices", "Gentle movement"]
        }
    }

    static func from(illumination: Double, isWaxing: Bool) -> MoonPhase {
        switch (illumination, isWaxing) {
        case (0..<0.03, _): return .newMoon
        case (0.03..<0.25, true): return .waxingCrescent
        case (0.25..<0.50, true): return .firstQuarter
        case (0.50..<0.75, true): return .waxingGibbous
        case (0.75..<0.97, true): return .fullMoon
        case (0.97...1.0, _): return .fullMoon
        case (0.75..<0.97, false): return .waningGibbous
        case (0.50..<0.75, false): return .lastQuarter
        case (0.25..<0.50, false): return .waningCrescent
        case (0.03..<0.25, false): return .waningCrescent
        default: return .newMoon
        }
    }
}

struct Recommendation: Identifiable, Codable, Equatable {
    let id: UUID
    let domain: LifeDomain
    let title: String
    let description: String
    let isPositive: Bool
    let priority: Int

    init(domain: LifeDomain, title: String, description: String, isPositive: Bool, priority: Int = 0) {
        self.id = UUID()
        self.domain = domain
        self.title = title
        self.description = description
        self.isPositive = isPositive
        self.priority = priority
    }
}
