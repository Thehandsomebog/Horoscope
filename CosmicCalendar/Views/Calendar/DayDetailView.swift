import SwiftUI

struct DayDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let cosmicDay: CosmicDay

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        scoresSection

                        moonPhaseSection

                        if !cosmicDay.activeRetrogrades.isEmpty {
                            retrogradesSection
                        }

                        recommendationsSection

                        planetaryPositionsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle(formattedDate)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(CosmicColors.primary)
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: cosmicDay.date)
    }

    private var headerSection: some View {
        CosmicCard {
            VStack(spacing: 16) {
                ScoreBadge(score: cosmicDay.overallScore, size: .large)

                Text(cosmicDay.scoreCategory.description)
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.text)
                    .multilineTextAlignment(.center)

                Text("\(cosmicDay.scoreCategory.emoji) \(cosmicDay.scoreCategory.rawValue) Cosmic Day")
                    .font(CosmicTypography.subheadline)
                    .foregroundColor(CosmicColors.text.opacity(0.7))
            }
        }
    }

    private var scoresSection: some View {
        CosmicCard {
            VStack(spacing: 16) {
                Text("Life Areas")
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.text)
                    .frame(maxWidth: .infinity, alignment: .leading)

                DomainScoreRow(domain: .relationships, score: cosmicDay.relationshipScore)
                Divider()
                DomainScoreRow(domain: .career, score: cosmicDay.careerScore)
                Divider()
                DomainScoreRow(domain: .health, score: cosmicDay.healthScore)
            }
        }
    }

    private var moonPhaseSection: some View {
        CosmicCard {
            VStack(spacing: 16) {
                HStack {
                    Text("Moon Phase")
                        .font(CosmicTypography.headline)
                        .foregroundColor(CosmicColors.text)

                    Spacer()

                    MoonPhaseView(phase: cosmicDay.moonPhase, size: 40)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(cosmicDay.moonPhase.rawValue)
                        .font(CosmicTypography.title3)
                        .foregroundColor(CosmicColors.text)

                    Text(cosmicDay.moonPhase.description)
                        .font(CosmicTypography.subheadline)
                        .foregroundColor(CosmicColors.text.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Good for:")
                        .font(CosmicTypography.caption)
                        .foregroundColor(CosmicColors.text.opacity(0.6))

                    FlowLayout(spacing: 8) {
                        ForEach(cosmicDay.moonPhase.activities, id: \.self) { activity in
                            Text(activity)
                                .font(CosmicTypography.caption)
                                .foregroundColor(CosmicColors.text)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(CosmicColors.secondary)
                                )
                        }
                    }
                }
            }
        }
    }

    private var retrogradesSection: some View {
        CosmicCard {
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .foregroundColor(CosmicColors.challenging)

                    Text("Active Retrogrades")
                        .font(CosmicTypography.headline)
                        .foregroundColor(CosmicColors.text)

                    Spacer()
                }

                ForEach(cosmicDay.activeRetrogrades, id: \.rawValue) { planet in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(planet.symbol)
                                .font(CosmicTypography.planetSymbol)

                            Text("\(planet.rawValue) Retrograde")
                                .font(CosmicTypography.bodyBold)
                                .foregroundColor(CosmicColors.text)
                        }

                        Text(planet.retrogradeImpact)
                            .font(CosmicTypography.caption)
                            .foregroundColor(CosmicColors.text.opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(CosmicColors.challenging.opacity(0.1))
                    )
                }
            }
        }
    }

    private var recommendationsSection: some View {
        VStack(spacing: 12) {
            Text("Today's Guidance")
                .font(CosmicTypography.headline)
                .foregroundColor(CosmicColors.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(cosmicDay.recommendations) { recommendation in
                RecommendationCard(recommendation: recommendation)
            }
        }
    }

    private var planetaryPositionsSection: some View {
        CosmicCard {
            VStack(spacing: 16) {
                Text("Planetary Positions")
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.text)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(cosmicDay.planetaryPositions) { position in
                        HStack(spacing: 8) {
                            Text(position.planet.symbol)
                                .font(CosmicTypography.planetSymbol)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(position.planet.rawValue)
                                    .font(CosmicTypography.caption)
                                    .foregroundColor(CosmicColors.text.opacity(0.6))

                                Text(position.formattedPosition)
                                    .font(CosmicTypography.subheadline)
                                    .foregroundColor(CosmicColors.text)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width && x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                maxHeight = max(maxHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: width, height: y + maxHeight)
        }
    }
}

#Preview {
    DayDetailView(
        cosmicDay: CosmicDay(
            id: Date(),
            date: Date(),
            overallScore: 7.5,
            relationshipScore: 8.0,
            careerScore: 6.5,
            healthScore: 7.0,
            moonPhase: .waxingGibbous,
            planetaryPositions: [],
            activeRetrogrades: [.mercury],
            significantAspects: [],
            recommendations: [
                Recommendation(
                    domain: .relationships,
                    title: "Express Your Feelings",
                    description: "A good day for heart-to-heart conversations.",
                    isPositive: true
                )
            ]
        )
    )
}
