import Foundation

struct PlanetaryPosition: Codable, Equatable, Identifiable {
    var id: String { planet.rawValue }

    let planet: Planet
    let longitude: Double
    let latitude: Double
    let distance: Double
    let speedLongitude: Double
    let isRetrograde: Bool

    var sign: ZodiacSign {
        ZodiacSign.from(degree: longitude)
    }

    var degreeInSign: Double {
        longitude.truncatingRemainder(dividingBy: 30)
    }

    var formattedPosition: String {
        let degrees = Int(degreeInSign)
        let minutes = Int((degreeInSign - Double(degrees)) * 60)
        let retrogradeSymbol = isRetrograde ? " R" : ""
        return "\(sign.symbol) \(degrees)°\(minutes)'\(retrogradeSymbol)"
    }
}

enum Planet: String, Codable, CaseIterable {
    case sun = "Sun"
    case moon = "Moon"
    case mercury = "Mercury"
    case venus = "Venus"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case uranus = "Uranus"
    case neptune = "Neptune"
    case pluto = "Pluto"

    var symbol: String {
        switch self {
        case .sun: return "☉"
        case .moon: return "☽"
        case .mercury: return "☿"
        case .venus: return "♀"
        case .mars: return "♂"
        case .jupiter: return "♃"
        case .saturn: return "♄"
        case .uranus: return "♅"
        case .neptune: return "♆"
        case .pluto: return "♇"
        }
    }

    var canBeRetrograde: Bool {
        switch self {
        case .sun, .moon:
            return false
        default:
            return true
        }
    }

    var domain: [LifeDomain] {
        switch self {
        case .sun: return [.career, .health]
        case .moon: return [.relationships, .health]
        case .mercury: return [.career, .relationships]
        case .venus: return [.relationships]
        case .mars: return [.career, .health]
        case .jupiter: return [.career, .relationships]
        case .saturn: return [.career]
        case .uranus: return [.career, .relationships]
        case .neptune: return [.relationships, .health]
        case .pluto: return [.relationships, .health]
        }
    }

    var retrogradeImpact: String {
        switch self {
        case .mercury:
            return "Communication delays, technology issues, travel disruptions. Review and revise rather than start new projects."
        case .venus:
            return "Relationship reassessment, financial caution. Not ideal for major purchases or new relationships."
        case .mars:
            return "Lower energy, frustration with progress. Focus on completing rather than starting."
        case .jupiter:
            return "Internal growth and reflection. Good for spiritual development."
        case .saturn:
            return "Review responsibilities and structures. Lessons from the past resurface."
        case .uranus:
            return "Internal revolution. Reassess need for freedom and change."
        case .neptune:
            return "Dreams and illusions clarify. Spiritual insights emerge."
        case .pluto:
            return "Deep psychological transformation. Hidden truths emerge."
        default:
            return ""
        }
    }
}

enum LifeDomain: String, Codable, CaseIterable {
    case relationships = "Relationships"
    case career = "Career"
    case health = "Health"

    var icon: String {
        switch self {
        case .relationships: return "heart.fill"
        case .career: return "briefcase.fill"
        case .health: return "leaf.fill"
        }
    }

    var description: String {
        switch self {
        case .relationships: return "Love, friendships, and connections"
        case .career: return "Work, finances, and ambitions"
        case .health: return "Wellness, energy, and self-care"
        }
    }
}

enum Aspect: String, Codable, CaseIterable {
    case conjunction = "Conjunction"
    case sextile = "Sextile"
    case square = "Square"
    case trine = "Trine"
    case opposition = "Opposition"

    var orb: Double {
        switch self {
        case .conjunction: return 8.0
        case .sextile: return 6.0
        case .square: return 7.0
        case .trine: return 8.0
        case .opposition: return 8.0
        }
    }

    var angle: Double {
        switch self {
        case .conjunction: return 0.0
        case .sextile: return 60.0
        case .square: return 90.0
        case .trine: return 120.0
        case .opposition: return 180.0
        }
    }

    var symbol: String {
        switch self {
        case .conjunction: return "☌"
        case .sextile: return "⚹"
        case .square: return "□"
        case .trine: return "△"
        case .opposition: return "☍"
        }
    }

    var isHarmonious: Bool {
        switch self {
        case .trine, .sextile: return true
        case .conjunction: return true
        case .square, .opposition: return false
        }
    }

    var scoreModifier: Double {
        switch self {
        case .trine: return 1.5
        case .sextile: return 1.0
        case .conjunction: return 0.5
        case .square: return -1.0
        case .opposition: return -1.5
        }
    }
}

struct PlanetaryAspect: Codable, Equatable {
    let planet1: Planet
    let planet2: Planet
    let aspect: Aspect
    let orb: Double
    let isApplying: Bool

    var description: String {
        "\(planet1.rawValue) \(aspect.symbol) \(planet2.rawValue)"
    }
}
