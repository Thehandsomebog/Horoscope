import SwiftUI
import SwiftData

struct TodayView: View {
    @Query private var users: [User]
    @State private var cosmicDay: CosmicDay?
    @State private var birthChart: BirthChart?
    @State private var isLoading: Bool = true

    private let scoreCalculator = CosmicScoreCalculator.shared
    private let ephemeris = EphemerisService.shared

    private var user: User? { users.first }

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicColors.background
                    .ignoresSafeArea()

                if isLoading {
                    LoadingView(message: "Reading the cosmos...")
                } else if let day = cosmicDay {
                    ScrollView {
                        VStack(spacing: 24) {
                            greetingSection

                            scoreSection(day: day)

                            moonPhaseSection(day: day)

                            domainScoresSection(day: day)

                            if !day.activeRetrogrades.isEmpty {
                                retrogradeAlertSection(retrogrades: day.activeRetrogrades)
                            }

                            recommendationsSection(day: day)

                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadTodayData()
            }
        }
    }

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(greetingText)
                .font(CosmicTypography.title2)
                .foregroundColor(CosmicColors.text)

            if let user = user {
                Text("Welcome back, \(user.name)")
                    .font(CosmicTypography.subheadline)
                    .foregroundColor(CosmicColors.textSecondary)
            }

            Text(formattedDate)
                .font(CosmicTypography.caption)
                .foregroundColor(CosmicColors.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func scoreSection(day: CosmicDay) -> some View {
        CosmicCard {
            VStack(spacing: 16) {
                CosmicScoreIndicator(score: day.overallScore)

                Text(day.scoreCategory.description)
                    .font(CosmicTypography.subheadline)
                    .foregroundColor(CosmicColors.text.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func moonPhaseSection(day: CosmicDay) -> some View {
        CosmicCard {
            HStack(spacing: 16) {
                MoonPhaseView(phase: day.moonPhase, size: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(day.moonPhase.rawValue)
                        .font(CosmicTypography.headline)
                        .foregroundColor(CosmicColors.text)

                    Text(day.moonPhase.description)
                        .font(CosmicTypography.caption)
                        .foregroundColor(CosmicColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()
            }
        }
    }

    private func domainScoresSection(day: CosmicDay) -> some View {
        CosmicCard {
            VStack(spacing: 16) {
                Text("Life Areas Today")
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.text)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ScoreProgressBar(score: day.relationshipScore, domain: .relationships)
                ScoreProgressBar(score: day.careerScore, domain: .career)
                ScoreProgressBar(score: day.healthScore, domain: .health)
            }
        }
    }

    private func retrogradeAlertSection(retrogrades: [Planet]) -> some View {
        CosmicCard {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(CosmicColors.challenging)
                        .accessibilityHidden(true)

                    Text("Retrograde Alert")
                        .font(CosmicTypography.headline)
                        .foregroundColor(CosmicColors.text)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(retrogrades, id: \.rawValue) { planet in
                        HStack(spacing: 8) {
                            Text(planet.symbol)
                                .font(CosmicTypography.planetSymbol())
                                .accessibilityHidden(true)

                            Text("\(planet.rawValue) is retrograde")
                                .font(CosmicTypography.subheadline)
                                .foregroundColor(CosmicColors.textSecondary)
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(planet.rawValue) is retrograde")
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(CosmicColors.challenging.opacity(0.3), lineWidth: 1)
        )
    }

    private func recommendationsSection(day: CosmicDay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Guidance")
                .font(CosmicTypography.headline)
                .foregroundColor(CosmicColors.text)

            ForEach(day.recommendations.prefix(3)) { recommendation in
                RecommendationCard(recommendation: recommendation)
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }

    private func loadTodayData() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let user = user {
                birthChart = ephemeris.calculateBirthChart(for: user)
            }

            cosmicDay = scoreCalculator.calculateCosmicDay(for: Date(), birthChart: birthChart)
            isLoading = false
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: User.self, inMemory: true)
}
