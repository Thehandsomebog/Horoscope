import SwiftUI

// MARK: - Cosmic Card

struct CosmicCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: CosmicColors.text.opacity(0.08), radius: 12, x: 0, y: 4)
            )
    }
}

// MARK: - Cosmic Button

struct CosmicButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary
    var accessibilityHint: String?

    enum ButtonStyle {
        case primary
        case secondary
        case outline

        var backgroundColor: Color {
            switch self {
            case .primary: return CosmicColors.primary
            case .secondary: return CosmicColors.accent
            case .outline: return .clear
            }
        }

        var foregroundColor: Color {
            switch self {
            case .primary, .secondary: return .white
            case .outline: return CosmicColors.primary
            }
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CosmicTypography.headline)
                .foregroundColor(style.foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(style.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    style == .outline ? CosmicColors.primary : .clear,
                                    lineWidth: 2
                                )
                        )
                )
        }
        .accessibilityHint(accessibilityHint ?? "")
    }
}

// MARK: - Cosmic Text Field

struct CosmicTextField: View {
    let placeholder: String
    @Binding var text: String
    var icon: String?

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(CosmicColors.accent)
                    .frame(width: 24)
                    .accessibilityHidden(true) // Decorative icon
            }

            TextField(placeholder, text: $text)
                .font(CosmicTypography.body)
                .foregroundColor(CosmicColors.text)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(CosmicColors.secondary)
        )
    }
}

// MARK: - Score Badge

struct ScoreBadge: View {
    let score: Double
    var size: Size = .medium

    enum Size {
        case small, medium, large

        var dimension: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 56
            case .large: return 80
            }
        }

        var font: Font {
            switch self {
            case .small: return CosmicTypography.headline
            case .medium: return CosmicTypography.title2
            case .large: return CosmicTypography.cosmicScore()
            }
        }
    }

    private var scoreCategory: String {
        switch score {
        case 8.5...10: return "excellent"
        case 7...8.49: return "good"
        case 5...6.99: return "neutral"
        case 3...4.99: return "challenging"
        default: return "difficult"
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(CosmicColors.scoreColor(for: score).opacity(0.2))

            Circle()
                .strokeBorder(CosmicColors.scoreColor(for: score), lineWidth: 3)

            Text(String(format: "%.1f", score))
                .font(size.font)
                .foregroundColor(CosmicColors.scoreTextColor(for: score))
                .minimumScaleFactor(0.7)
        }
        .frame(width: size.dimension, height: size.dimension)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Score: \(String(format: "%.1f", score)) out of 10, \(scoreCategory)")
    }
}

// MARK: - Moon Phase View

struct MoonPhaseView: View {
    let phase: MoonPhase
    var size: CGFloat = 48

    var body: some View {
        Text(phase.symbol)
            .font(.system(size: size))
            .accessibilityLabel("Moon phase: \(phase.rawValue)")
    }
}

// MARK: - Planet Badge

struct PlanetBadge: View {
    let planet: Planet
    var isRetrograde: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Text(planet.symbol)
                .font(CosmicTypography.planetSymbol())
                .accessibilityHidden(true) // Symbol is decorative

            if isRetrograde {
                Text("R")
                    .font(CosmicTypography.caption)
                    .foregroundColor(CosmicColors.challenging)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isRetrograde ? CosmicColors.challenging.opacity(0.2) : CosmicColors.secondary)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(planet.rawValue)\(isRetrograde ? ", retrograde" : "")")
    }
}

// MARK: - Zodiac Badge

struct ZodiacBadge: View {
    let sign: ZodiacSign

    var body: some View {
        HStack(spacing: 6) {
            Text(sign.symbol)
                .font(CosmicTypography.zodiacSymbol())
                .accessibilityHidden(true) // Symbol is decorative

            Text(sign.rawValue)
                .font(CosmicTypography.caption)
                .foregroundColor(CosmicColors.text)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(CosmicColors.elementColor(for: sign.element).opacity(0.2))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(sign.rawValue), \(sign.element.rawValue) sign")
    }
}

// MARK: - Domain Score Row

struct DomainScoreRow: View {
    let domain: LifeDomain
    let score: Double

    var body: some View {
        HStack {
            Image(systemName: domain.icon)
                .foregroundColor(CosmicColors.accent)
                .frame(width: 24)
                .accessibilityHidden(true) // Icon is decorative, text provides meaning

            Text(domain.rawValue)
                .font(CosmicTypography.body)
                .foregroundColor(CosmicColors.text)

            Spacer()

            ScoreBadge(score: score, size: .small)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(domain.rawValue): \(String(format: "%.1f", score)) out of 10")
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let recommendation: Recommendation

    private var typeLabel: String {
        recommendation.isPositive ? "Opportunity" : "Challenge"
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: recommendation.isPositive ? "plus.circle.fill" : "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundColor(recommendation.isPositive ? CosmicColors.good : CosmicColors.challenging)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(recommendation.isPositive
                              ? CosmicColors.good.opacity(0.2)
                              : CosmicColors.challenging.opacity(0.2))
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.text)

                Text(recommendation.description)
                    .font(CosmicTypography.subheadline)
                    .foregroundColor(CosmicColors.textSecondary)
                    .lineLimit(4)
                    .minimumScaleFactor(0.9)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(typeLabel) for \(recommendation.domain.rawValue): \(recommendation.title). \(recommendation.description)")
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(CosmicColors.primary)
                .accessibilityLabel("Loading")

            Text(message)
                .font(CosmicTypography.subheadline)
                .foregroundColor(CosmicColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CosmicColors.background)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

// MARK: - Constellation Background

struct ConstellationBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CosmicColors.background
                    .ignoresSafeArea()

                ForEach(0..<30, id: \.self) { _ in
                    Circle()
                        .fill(CosmicColors.cosmicGold.opacity(Double.random(in: 0.1...0.4)))
                        .frame(width: CGFloat.random(in: 2...6))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
        .accessibilityHidden(true) // Purely decorative background
    }
}

// MARK: - Accessibility Helpers

extension View {
    /// Marks an element as decorative (hidden from accessibility)
    func decorative() -> some View {
        self.accessibilityHidden(true)
    }

    /// Combines children into a single accessibility element with a custom label
    func accessibilityGroup(_ label: String) -> some View {
        self.accessibilityElement(children: .combine)
            .accessibilityLabel(label)
    }
}
