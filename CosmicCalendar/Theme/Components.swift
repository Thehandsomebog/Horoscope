import SwiftUI

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

struct CosmicButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonStyle = .primary

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
    }
}

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
            case .large: return CosmicTypography.cosmicScore
            }
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
                .foregroundColor(CosmicColors.scoreColor(for: score))
        }
        .frame(width: size.dimension, height: size.dimension)
    }
}

struct MoonPhaseView: View {
    let phase: MoonPhase
    var size: CGFloat = 48

    var body: some View {
        Text(phase.symbol)
            .font(.system(size: size))
    }
}

struct PlanetBadge: View {
    let planet: Planet
    var isRetrograde: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Text(planet.symbol)
                .font(CosmicTypography.planetSymbol)

            if isRetrograde {
                Text("R")
                    .font(CosmicTypography.caption)
                    .foregroundColor(CosmicColors.challenging)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(isRetrograde ? CosmicColors.challenging.opacity(0.2) : CosmicColors.secondary)
        )
    }
}

struct ZodiacBadge: View {
    let sign: ZodiacSign

    var body: some View {
        HStack(spacing: 6) {
            Text(sign.symbol)
                .font(CosmicTypography.zodiacSymbol)

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
    }
}

struct DomainScoreRow: View {
    let domain: LifeDomain
    let score: Double

    var body: some View {
        HStack {
            Image(systemName: domain.icon)
                .foregroundColor(CosmicColors.accent)
                .frame(width: 24)

            Text(domain.rawValue)
                .font(CosmicTypography.body)
                .foregroundColor(CosmicColors.text)

            Spacer()

            ScoreBadge(score: score, size: .small)
        }
        .padding(.vertical, 8)
    }
}

struct RecommendationCard: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: recommendation.domain.icon)
                .font(.system(size: 20))
                .foregroundColor(recommendation.isPositive ? CosmicColors.good : CosmicColors.challenging)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(recommendation.isPositive
                              ? CosmicColors.good.opacity(0.2)
                              : CosmicColors.challenging.opacity(0.2))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.text)

                Text(recommendation.description)
                    .font(CosmicTypography.subheadline)
                    .foregroundColor(CosmicColors.text.opacity(0.7))
                    .lineLimit(3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
    }
}

struct LoadingView: View {
    var message: String = "Loading..."

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(CosmicColors.primary)

            Text(message)
                .font(CosmicTypography.subheadline)
                .foregroundColor(CosmicColors.text.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(CosmicColors.background)
    }
}

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
    }
}
