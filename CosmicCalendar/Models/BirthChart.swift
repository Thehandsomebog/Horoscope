import Foundation

struct BirthChart: Codable, Equatable {
    let sunSign: ZodiacSign
    let moonSign: ZodiacSign
    let risingSign: ZodiacSign?
    let planetaryPositions: [PlanetaryPosition]
    let calculatedAt: Date

    var dominantElement: Element {
        var elementCounts: [Element: Int] = [:]
        for position in planetaryPositions {
            let element = position.sign.element
            elementCounts[element, default: 0] += 1
        }
        return elementCounts.max(by: { $0.value < $1.value })?.key ?? .fire
    }

    var dominantModality: Modality {
        var modalityCounts: [Modality: Int] = [:]
        for position in planetaryPositions {
            let modality = position.sign.modality
            modalityCounts[modality, default: 0] += 1
        }
        return modalityCounts.max(by: { $0.value < $1.value })?.key ?? .cardinal
    }
}

enum ZodiacSign: String, Codable, CaseIterable {
    case aries = "Aries"
    case taurus = "Taurus"
    case gemini = "Gemini"
    case cancer = "Cancer"
    case leo = "Leo"
    case virgo = "Virgo"
    case libra = "Libra"
    case scorpio = "Scorpio"
    case sagittarius = "Sagittarius"
    case capricorn = "Capricorn"
    case aquarius = "Aquarius"
    case pisces = "Pisces"

    var symbol: String {
        switch self {
        case .aries: return "♈"
        case .taurus: return "♉"
        case .gemini: return "♊"
        case .cancer: return "♋"
        case .leo: return "♌"
        case .virgo: return "♍"
        case .libra: return "♎"
        case .scorpio: return "♏"
        case .sagittarius: return "♐"
        case .capricorn: return "♑"
        case .aquarius: return "♒"
        case .pisces: return "♓"
        }
    }

    var element: Element {
        switch self {
        case .aries, .leo, .sagittarius: return .fire
        case .taurus, .virgo, .capricorn: return .earth
        case .gemini, .libra, .aquarius: return .air
        case .cancer, .scorpio, .pisces: return .water
        }
    }

    var modality: Modality {
        switch self {
        case .aries, .cancer, .libra, .capricorn: return .cardinal
        case .taurus, .leo, .scorpio, .aquarius: return .fixed
        case .gemini, .virgo, .sagittarius, .pisces: return .mutable
        }
    }

    var ruler: Planet {
        switch self {
        case .aries: return .mars
        case .taurus: return .venus
        case .gemini: return .mercury
        case .cancer: return .moon
        case .leo: return .sun
        case .virgo: return .mercury
        case .libra: return .venus
        case .scorpio: return .pluto
        case .sagittarius: return .jupiter
        case .capricorn: return .saturn
        case .aquarius: return .uranus
        case .pisces: return .neptune
        }
    }

    static func from(degree: Double) -> ZodiacSign {
        let normalizedDegree = degree.truncatingRemainder(dividingBy: 360)
        let signIndex = Int(normalizedDegree / 30)
        return ZodiacSign.allCases[signIndex]
    }
}

enum Element: String, Codable {
    case fire = "Fire"
    case earth = "Earth"
    case air = "Air"
    case water = "Water"

    var description: String {
        switch self {
        case .fire: return "Passionate, energetic, and action-oriented"
        case .earth: return "Practical, grounded, and reliable"
        case .air: return "Intellectual, communicative, and social"
        case .water: return "Emotional, intuitive, and nurturing"
        }
    }

    var color: String {
        switch self {
        case .fire: return "orange"
        case .earth: return "brown"
        case .air: return "cyan"
        case .water: return "blue"
        }
    }
}

enum Modality: String, Codable {
    case cardinal = "Cardinal"
    case fixed = "Fixed"
    case mutable = "Mutable"

    var description: String {
        switch self {
        case .cardinal: return "Initiators and leaders"
        case .fixed: return "Stabilizers and maintainers"
        case .mutable: return "Adapters and communicators"
        }
    }
}
