import SwiftUI
import SwiftData

struct ChartRevealView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    let name: String
    let birthDate: Date
    let birthTime: Date?
    let location: LocationResult

    @State private var birthChart: BirthChart?
    @State private var isCalculating: Bool = true
    @State private var showContent: Bool = false
    @State private var animationProgress: Double = 0

    private let ephemeris = EphemerisService.shared

    var body: some View {
        ZStack {
            ConstellationBackground()

            if isCalculating {
                calculatingView
            } else if let chart = birthChart {
                chartRevealContent(chart: chart)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            calculateChart()
        }
    }

    private var calculatingView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(CosmicColors.primary.opacity(0.3), lineWidth: 4)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: animationProgress)
                    .stroke(CosmicColors.primary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(CosmicColors.cosmicGold)
            }
            .onAppear {
                withAnimation(.linear(duration: 2.5)) {
                    animationProgress = 1.0
                }
            }

            Text("Calculating your cosmic blueprint...")
                .font(CosmicTypography.headline)
                .foregroundColor(CosmicColors.text)

            Text("Analyzing planetary positions at the moment of your birth")
                .font(CosmicTypography.subheadline)
                .foregroundColor(CosmicColors.text.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private func chartRevealContent(chart: BirthChart) -> some View {
        ScrollView {
            VStack(spacing: 32) {
                welcomeHeader(chart: chart)

                signCards(chart: chart)

                elementCard(chart: chart)

                continueButton
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
        }
    }

    private func welcomeHeader(chart: BirthChart) -> some View {
        VStack(spacing: 16) {
            Text("Welcome, \(name)")
                .font(CosmicTypography.largeTitle)
                .foregroundColor(CosmicColors.text)

            Text("Your Cosmic Blueprint")
                .font(CosmicTypography.title3)
                .foregroundColor(CosmicColors.accent)
        }
    }

    private func signCards(chart: BirthChart) -> some View {
        VStack(spacing: 16) {
            SignRevealCard(
                title: "Sun Sign",
                sign: chart.sunSign,
                description: "Your core identity and life force",
                icon: "sun.max.fill"
            )

            SignRevealCard(
                title: "Moon Sign",
                sign: chart.moonSign,
                description: "Your emotional nature and inner self",
                icon: "moon.fill"
            )

            if let rising = chart.risingSign {
                SignRevealCard(
                    title: "Rising Sign",
                    sign: rising,
                    description: "How others perceive you",
                    icon: "sunrise.fill"
                )
            }
        }
    }

    private func elementCard(chart: BirthChart) -> some View {
        CosmicCard {
            VStack(spacing: 12) {
                Text("Dominant Element")
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.text)

                HStack(spacing: 12) {
                    Image(systemName: elementIcon(chart.dominantElement))
                        .font(.system(size: 32))
                        .foregroundColor(CosmicColors.elementColor(for: chart.dominantElement))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(chart.dominantElement.rawValue)
                            .font(CosmicTypography.title3)
                            .foregroundColor(CosmicColors.text)

                        Text(chart.dominantElement.description)
                            .font(CosmicTypography.caption)
                            .foregroundColor(CosmicColors.text.opacity(0.7))
                    }
                }
            }
        }
    }

    private var continueButton: some View {
        CosmicButton(title: "Start Your Cosmic Journey") {
            saveUserAndContinue()
        }
        .padding(.top, 16)
    }

    private func calculateChart() {
        let user = User(
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocationName: location.name,
            birthLatitude: location.coordinate.latitude,
            birthLongitude: location.coordinate.longitude,
            birthTimezone: location.timezone.identifier
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let chart = ephemeris.calculateBirthChart(for: user)
            birthChart = chart
            isCalculating = false

            withAnimation(.easeOut(duration: 0.5)) {
                showContent = true
            }
        }
    }

    private func saveUserAndContinue() {
        let user = User(
            name: name,
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocationName: location.name,
            birthLatitude: location.coordinate.latitude,
            birthLongitude: location.coordinate.longitude,
            birthTimezone: location.timezone.identifier
        )

        modelContext.insert(user)

        do {
            try modelContext.save()
            appState.completeOnboarding()
        } catch {
            print("Failed to save user: \(error)")
        }
    }

    private func elementIcon(_ element: Element) -> String {
        switch element {
        case .fire: return "flame.fill"
        case .earth: return "leaf.fill"
        case .air: return "wind"
        case .water: return "drop.fill"
        }
    }
}

struct SignRevealCard: View {
    let title: String
    let sign: ZodiacSign
    let description: String
    let icon: String

    var body: some View {
        CosmicCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(CosmicColors.elementColor(for: sign.element).opacity(0.2))
                        .frame(width: 60, height: 60)

                    Text(sign.symbol)
                        .font(CosmicTypography.zodiacSymbol)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: icon)
                            .font(.caption)
                            .foregroundColor(CosmicColors.cosmicGold)

                        Text(title)
                            .font(CosmicTypography.caption)
                            .foregroundColor(CosmicColors.text.opacity(0.6))
                    }

                    Text(sign.rawValue)
                        .font(CosmicTypography.title2)
                        .foregroundColor(CosmicColors.text)

                    Text(description)
                        .font(CosmicTypography.caption)
                        .foregroundColor(CosmicColors.text.opacity(0.7))
                }

                Spacer()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChartRevealView(
            name: "Luna",
            birthDate: Date(),
            birthTime: Date(),
            location: LocationResult(
                name: "New York, NY, USA",
                coordinate: .init(latitude: 40.7128, longitude: -74.0060),
                timezone: TimeZone(identifier: "America/New_York")!
            )
        )
        .environmentObject(AppState())
        .modelContainer(for: User.self, inMemory: true)
    }
}
