import Foundation

class CosmicScoreCalculator {
    static let shared = CosmicScoreCalculator()

    private let ephemeris = EphemerisService.shared

    private init() {}

    func calculateCosmicDay(for date: Date, birthChart: BirthChart?) -> CosmicDay {
        let positions = ephemeris.calculatePlanetaryPositions(for: date)
        let moonPhase = ephemeris.calculateMoonPhase(for: date)
        let retrogrades = ephemeris.getActiveRetrogrades(for: date)

        var aspects: [PlanetaryAspect] = []
        if let birthChart = birthChart {
            aspects = ephemeris.calculateAspects(between: positions, and: birthChart.planetaryPositions)
        }

        let overallScore = calculateOverallScore(
            moonPhase: moonPhase,
            retrogrades: retrogrades,
            aspects: aspects
        )

        let relationshipScore = calculateDomainScore(
            domain: .relationships,
            positions: positions,
            retrogrades: retrogrades,
            aspects: aspects,
            moonPhase: moonPhase
        )

        let careerScore = calculateDomainScore(
            domain: .career,
            positions: positions,
            retrogrades: retrogrades,
            aspects: aspects,
            moonPhase: moonPhase
        )

        let healthScore = calculateDomainScore(
            domain: .health,
            positions: positions,
            retrogrades: retrogrades,
            aspects: aspects,
            moonPhase: moonPhase
        )

        let recommendations = RecommendationEngine.shared.generateRecommendations(
            moonPhase: moonPhase,
            retrogrades: retrogrades,
            aspects: aspects,
            relationshipScore: relationshipScore,
            careerScore: careerScore,
            healthScore: healthScore
        )

        return CosmicDay(
            id: date,
            date: date,
            overallScore: overallScore,
            relationshipScore: relationshipScore,
            careerScore: careerScore,
            healthScore: healthScore,
            moonPhase: moonPhase,
            planetaryPositions: positions,
            activeRetrogrades: retrogrades,
            significantAspects: aspects,
            recommendations: recommendations
        )
    }

    private func calculateOverallScore(
        moonPhase: MoonPhase,
        retrogrades: [Planet],
        aspects: [PlanetaryAspect]
    ) -> Double {
        var score = 5.0

        score += moonPhase.scoreModifier

        for planet in retrogrades {
            switch planet {
            case .mercury:
                score -= 1.5
            case .venus:
                score -= 1.0
            case .mars:
                score -= 0.5
            case .jupiter, .saturn:
                score -= 0.25
            default:
                score -= 0.1
            }
        }

        for aspect in aspects {
            let modifier = aspect.aspect.scoreModifier * (aspect.isApplying ? 1.2 : 0.8)
            score += modifier * 0.3
        }

        return clamp(score, min: 1.0, max: 10.0)
    }

    private func calculateDomainScore(
        domain: LifeDomain,
        positions: [PlanetaryPosition],
        retrogrades: [Planet],
        aspects: [PlanetaryAspect],
        moonPhase: MoonPhase
    ) -> Double {
        var score = 5.0

        let relevantPlanets = Planet.allCases.filter { $0.domain.contains(domain) }

        for planet in relevantPlanets {
            if retrogrades.contains(planet) {
                switch planet {
                case .mercury where domain == .career:
                    score -= 1.5
                case .venus where domain == .relationships:
                    score -= 1.5
                case .mars where domain == .health:
                    score -= 1.0
                default:
                    score -= 0.5
                }
            }
        }

        let relevantAspects = aspects.filter { aspect in
            relevantPlanets.contains(aspect.planet1) || relevantPlanets.contains(aspect.planet2)
        }

        for aspect in relevantAspects {
            score += aspect.aspect.scoreModifier * 0.5
        }

        switch domain {
        case .relationships:
            switch moonPhase {
            case .fullMoon:
                score += 1.0
            case .newMoon:
                score += 0.5
            case .waningCrescent, .waningGibbous:
                score -= 0.25
            default:
                break
            }
        case .career:
            switch moonPhase {
            case .waxingGibbous, .firstQuarter:
                score += 0.5
            case .fullMoon:
                score += 0.75
            case .waningCrescent:
                score -= 0.5
            default:
                break
            }
        case .health:
            switch moonPhase {
            case .newMoon:
                score += 0.5
            case .waningCrescent:
                score += 0.25
            case .fullMoon:
                score -= 0.25
            default:
                break
            }
        }

        return clamp(score, min: 1.0, max: 10.0)
    }

    func calculateScoresForMonth(year: Int, month: Int, birthChart: BirthChart?) -> [Date: CosmicDay] {
        var results: [Date: CosmicDay] = [:]

        let calendar = Calendar.current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return results
        }

        for day in range {
            components.day = day
            if let date = calendar.date(from: components) {
                results[date] = calculateCosmicDay(for: date, birthChart: birthChart)
            }
        }

        return results
    }

    private func clamp(_ value: Double, min: Double, max: Double) -> Double {
        return Swift.min(Swift.max(value, min), max)
    }
}
