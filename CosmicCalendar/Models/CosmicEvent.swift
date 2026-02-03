import Foundation

struct CosmicEvent: Identifiable, Codable {
    let id: UUID
    let type: EventType
    let planet: Planet?
    let startDate: Date
    let endDate: Date?
    let title: String
    let description: String
    let impact: Impact

    init(
        type: EventType,
        planet: Planet? = nil,
        startDate: Date,
        endDate: Date? = nil,
        title: String,
        description: String,
        impact: Impact
    ) {
        self.id = UUID()
        self.type = type
        self.planet = planet
        self.startDate = startDate
        self.endDate = endDate
        self.title = title
        self.description = description
        self.impact = impact
    }

    var isActive: Bool {
        let now = Date()
        if let endDate = endDate {
            return now >= startDate && now <= endDate
        }
        return Calendar.current.isDate(now, inSameDayAs: startDate)
    }

    var daysUntilStart: Int? {
        let now = Date()
        guard startDate > now else { return nil }
        return Calendar.current.dateComponents([.day], from: now, to: startDate).day
    }

    var daysRemaining: Int? {
        guard let endDate = endDate else { return nil }
        let now = Date()
        guard now <= endDate else { return nil }
        return Calendar.current.dateComponents([.day], from: now, to: endDate).day
    }
}

enum EventType: String, Codable {
    case retrograde = "Retrograde"
    case directStation = "Direct Station"
    case newMoon = "New Moon"
    case fullMoon = "Full Moon"
    case eclipse = "Eclipse"
    case planetaryIngress = "Planetary Ingress"
    case majorAspect = "Major Aspect"

    var icon: String {
        switch self {
        case .retrograde: return "arrow.uturn.backward.circle"
        case .directStation: return "arrow.forward.circle"
        case .newMoon: return "moon.fill"
        case .fullMoon: return "moon.circle.fill"
        case .eclipse: return "circle.lefthalf.filled"
        case .planetaryIngress: return "arrow.right.circle"
        case .majorAspect: return "star.circle"
        }
    }

    var color: String {
        switch self {
        case .retrograde: return "orange"
        case .directStation: return "green"
        case .newMoon: return "gray"
        case .fullMoon: return "yellow"
        case .eclipse: return "purple"
        case .planetaryIngress: return "blue"
        case .majorAspect: return "pink"
        }
    }
}

enum Impact: String, Codable {
    case veryPositive = "Very Positive"
    case positive = "Positive"
    case neutral = "Neutral"
    case challenging = "Challenging"
    case veryChallenging = "Very Challenging"

    var scoreModifier: Double {
        switch self {
        case .veryPositive: return 1.5
        case .positive: return 0.75
        case .neutral: return 0.0
        case .challenging: return -0.75
        case .veryChallenging: return -1.5
        }
    }

    var color: String {
        switch self {
        case .veryPositive: return "green"
        case .positive: return "teal"
        case .neutral: return "gray"
        case .challenging: return "orange"
        case .veryChallenging: return "red"
        }
    }
}
