import Foundation

class RecommendationEngine {
    static let shared = RecommendationEngine()

    private init() {}

    func generateRecommendations(
        moonPhase: MoonPhase,
        retrogrades: [Planet],
        aspects: [PlanetaryAspect],
        relationshipScore: Double,
        careerScore: Double,
        healthScore: Double
    ) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        recommendations.append(contentsOf: generateMoonPhaseRecommendations(moonPhase))
        recommendations.append(contentsOf: generateRetrogradeRecommendations(retrogrades))
        recommendations.append(contentsOf: generateDomainRecommendations(
            relationshipScore: relationshipScore,
            careerScore: careerScore,
            healthScore: healthScore
        ))

        return recommendations
            .sorted { $0.priority > $1.priority }
            .prefix(6)
            .map { $0 }
    }

    private func generateMoonPhaseRecommendations(_ moonPhase: MoonPhase) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        switch moonPhase {
        case .newMoon:
            recommendations.append(Recommendation(
                domain: .career,
                title: "Set New Intentions",
                description: "The new moon is perfect for starting fresh projects and setting goals for the coming weeks.",
                isPositive: true,
                priority: 3
            ))
            recommendations.append(Recommendation(
                domain: .health,
                title: "Begin a Wellness Routine",
                description: "Start that new health habit you've been considering. The energy supports fresh starts.",
                isPositive: true,
                priority: 2
            ))

        case .waxingCrescent, .waxingGibbous:
            recommendations.append(Recommendation(
                domain: .career,
                title: "Build Momentum",
                description: "Take action on your goals. The waxing moon supports growth and forward movement.",
                isPositive: true,
                priority: 2
            ))

        case .firstQuarter:
            recommendations.append(Recommendation(
                domain: .career,
                title: "Face Challenges Head-On",
                description: "This is a time for decisive action. Overcome obstacles blocking your progress.",
                isPositive: true,
                priority: 2
            ))

        case .fullMoon:
            recommendations.append(Recommendation(
                domain: .relationships,
                title: "Express Your Feelings",
                description: "Emotions are heightened. It's a powerful time for heart-to-heart conversations.",
                isPositive: true,
                priority: 3
            ))
            recommendations.append(Recommendation(
                domain: .health,
                title: "Practice Grounding",
                description: "Full moon energy can feel intense. Stay grounded with meditation or nature walks.",
                isPositive: true,
                priority: 2
            ))

        case .waningGibbous:
            recommendations.append(Recommendation(
                domain: .relationships,
                title: "Share Your Wisdom",
                description: "A good time to mentor others or express gratitude to those who've helped you.",
                isPositive: true,
                priority: 1
            ))

        case .lastQuarter:
            recommendations.append(Recommendation(
                domain: .health,
                title: "Release What No Longer Serves",
                description: "Let go of old habits, grudges, or patterns that are holding you back.",
                isPositive: true,
                priority: 2
            ))

        case .waningCrescent:
            recommendations.append(Recommendation(
                domain: .health,
                title: "Rest and Recharge",
                description: "Honor your need for rest. This is a time for reflection, not action.",
                isPositive: true,
                priority: 3
            ))
            recommendations.append(Recommendation(
                domain: .career,
                title: "Avoid Major Decisions",
                description: "Wait for the new moon before launching new projects or making big commitments.",
                isPositive: false,
                priority: 2
            ))
        }

        return recommendations
    }

    private func generateRetrogradeRecommendations(_ retrogrades: [Planet]) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        if retrogrades.contains(.mercury) {
            recommendations.append(Recommendation(
                domain: .career,
                title: "Double-Check Communications",
                description: "Mercury retrograde can cause misunderstandings. Review emails before sending and confirm appointments.",
                isPositive: false,
                priority: 4
            ))
            recommendations.append(Recommendation(
                domain: .career,
                title: "Back Up Your Data",
                description: "Technology glitches are common during Mercury retrograde. Protect your important files.",
                isPositive: false,
                priority: 3
            ))
            recommendations.append(Recommendation(
                domain: .relationships,
                title: "Pause Before Reacting",
                description: "Misunderstandings are likely. Take a breath before responding to avoid conflict.",
                isPositive: false,
                priority: 3
            ))
        }

        if retrogrades.contains(.venus) {
            recommendations.append(Recommendation(
                domain: .relationships,
                title: "Reflect on Relationship Patterns",
                description: "Venus retrograde invites you to examine what you truly value in relationships.",
                isPositive: true,
                priority: 3
            ))
            recommendations.append(Recommendation(
                domain: .relationships,
                title: "Avoid New Relationships",
                description: "Wait until Venus goes direct before starting a new romance or making relationship commitments.",
                isPositive: false,
                priority: 4
            ))
        }

        if retrogrades.contains(.mars) {
            recommendations.append(Recommendation(
                domain: .health,
                title: "Pace Yourself",
                description: "Energy levels may be lower than usual. Focus on completing rather than starting.",
                isPositive: false,
                priority: 3
            ))
            recommendations.append(Recommendation(
                domain: .career,
                title: "Avoid Aggressive Action",
                description: "Mars retrograde can lead to frustration. Channel energy into planning rather than pushing forward.",
                isPositive: false,
                priority: 2
            ))
        }

        return recommendations
    }

    private func generateDomainRecommendations(
        relationshipScore: Double,
        careerScore: Double,
        healthScore: Double
    ) -> [Recommendation] {
        var recommendations: [Recommendation] = []

        if relationshipScore >= 7.5 {
            recommendations.append(Recommendation(
                domain: .relationships,
                title: "Reach Out to Loved Ones",
                description: "Today's cosmic energy supports meaningful connections. Initiate plans with someone special.",
                isPositive: true,
                priority: 2
            ))
        } else if relationshipScore <= 4.0 {
            recommendations.append(Recommendation(
                domain: .relationships,
                title: "Practice Self-Love",
                description: "Turn inward today. Journaling or solo activities will feel more nourishing than socializing.",
                isPositive: false,
                priority: 2
            ))
        }

        if careerScore >= 7.5 {
            recommendations.append(Recommendation(
                domain: .career,
                title: "Take Initiative",
                description: "The stars favor bold career moves. Pitch that idea, ask for what you deserve.",
                isPositive: true,
                priority: 2
            ))
        } else if careerScore <= 4.0 {
            recommendations.append(Recommendation(
                domain: .career,
                title: "Focus on Routine Tasks",
                description: "Not ideal for major decisions or negotiations. Stick to your to-do list.",
                isPositive: false,
                priority: 2
            ))
        }

        if healthScore >= 7.5 {
            recommendations.append(Recommendation(
                domain: .health,
                title: "High Energy Day",
                description: "Great day for exercise, outdoor activities, or starting a new wellness practice.",
                isPositive: true,
                priority: 2
            ))
        } else if healthScore <= 4.0 {
            recommendations.append(Recommendation(
                domain: .health,
                title: "Gentle Self-Care",
                description: "Your body needs extra rest. Prioritize sleep, hydration, and gentle movement.",
                isPositive: false,
                priority: 2
            ))
        }

        return recommendations
    }
}
