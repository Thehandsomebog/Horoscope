import SwiftUI

struct CosmicScoreIndicator: View {
    let score: Double
    var showLabel: Bool = true
    var size: CGFloat = 120

    @State private var animatedScore: Double = 0

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(CosmicColors.text.opacity(0.1), lineWidth: 12)

                Circle()
                    .trim(from: 0, to: animatedScore / 10)
                    .stroke(
                        AngularGradient(
                            colors: [
                                CosmicColors.scoreColor(for: score).opacity(0.5),
                                CosmicColors.scoreColor(for: score)
                            ],
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text(String(format: "%.1f", animatedScore))
                        .font(CosmicTypography.displayMedium)
                        .foregroundColor(CosmicColors.scoreColor(for: score))

                    if showLabel {
                        Text("Cosmic Score")
                            .font(CosmicTypography.caption)
                            .foregroundColor(CosmicColors.text.opacity(0.6))
                    }
                }
            }
            .frame(width: size, height: size)
        }
        .onAppear {
            withAnimation(.spring(duration: 1.0, bounce: 0.3)) {
                animatedScore = score
            }
        }
        .onChange(of: score) { _, newValue in
            withAnimation(.spring(duration: 0.5)) {
                animatedScore = newValue
            }
        }
    }
}

struct CosmicScoreRing: View {
    let score: Double
    var ringWidth: CGFloat = 6
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            Circle()
                .stroke(CosmicColors.scoreColor(for: score).opacity(0.2), lineWidth: ringWidth)

            Circle()
                .trim(from: 0, to: score / 10)
                .stroke(
                    CosmicColors.scoreColor(for: score),
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text(String(format: "%.0f", score))
                .font(CosmicTypography.headline)
                .foregroundColor(CosmicColors.scoreColor(for: score))
        }
        .frame(width: size, height: size)
    }
}

struct ScoreProgressBar: View {
    let score: Double
    let domain: LifeDomain

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: domain.icon)
                    .foregroundColor(CosmicColors.accent)

                Text(domain.rawValue)
                    .font(CosmicTypography.subheadline)
                    .foregroundColor(CosmicColors.text)

                Spacer()

                Text(String(format: "%.1f", score))
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.scoreColor(for: score))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CosmicColors.text.opacity(0.1))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(CosmicColors.scoreColor(for: score))
                        .frame(width: geometry.size.width * (score / 10), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct TrendIndicator: View {
    let currentScore: Double
    let previousScore: Double

    private var trend: Trend {
        let difference = currentScore - previousScore
        if difference > 0.5 {
            return .up
        } else if difference < -0.5 {
            return .down
        } else {
            return .stable
        }
    }

    enum Trend {
        case up, down, stable

        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }

        var color: Color {
            switch self {
            case .up: return CosmicColors.good
            case .down: return CosmicColors.challenging
            case .stable: return CosmicColors.neutral
            }
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: trend.icon)
                .font(.caption)

            Text(trendText)
                .font(CosmicTypography.caption)
        }
        .foregroundColor(trend.color)
    }

    private var trendText: String {
        let difference = abs(currentScore - previousScore)
        switch trend {
        case .up:
            return "+\(String(format: "%.1f", difference))"
        case .down:
            return "-\(String(format: "%.1f", difference))"
        case .stable:
            return "Stable"
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        CosmicScoreIndicator(score: 7.5)

        HStack(spacing: 20) {
            CosmicScoreRing(score: 8.5)
            CosmicScoreRing(score: 5.0)
            CosmicScoreRing(score: 3.0)
        }

        VStack(spacing: 16) {
            ScoreProgressBar(score: 8.0, domain: .relationships)
            ScoreProgressBar(score: 6.5, domain: .career)
            ScoreProgressBar(score: 4.0, domain: .health)
        }
        .padding(.horizontal, 20)

        HStack(spacing: 20) {
            TrendIndicator(currentScore: 7.5, previousScore: 6.0)
            TrendIndicator(currentScore: 5.0, previousScore: 6.5)
            TrendIndicator(currentScore: 7.0, previousScore: 7.0)
        }
    }
    .padding()
    .background(CosmicColors.background)
}
