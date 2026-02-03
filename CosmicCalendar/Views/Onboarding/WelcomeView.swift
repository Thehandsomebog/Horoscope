import SwiftUI

struct WelcomeView: View {
    @State private var currentPage: Int = 0
    @State private var showBirthDataInput: Bool = false

    private let pages: [(title: String, description: String, icon: String)] = [
        (
            "Welcome to Cosmic Calendar",
            "Discover how the stars and planets influence your daily life and help you make better decisions.",
            "sparkles"
        ),
        (
            "Personalized Guidance",
            "Get tailored recommendations for relationships, career, and health based on your unique birth chart.",
            "person.fill.viewfinder"
        ),
        (
            "Cosmic Calendar",
            "Plan your days around cosmic energy. See which days are favorable for important decisions.",
            "calendar.badge.clock"
        ),
        (
            "Stay Informed",
            "Receive alerts for Mercury retrograde, full moons, and other significant cosmic events.",
            "bell.badge"
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                ConstellationBackground()

                VStack(spacing: 0) {
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            WelcomePageView(
                                title: pages[index].title,
                                description: pages[index].description,
                                icon: pages[index].icon
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    VStack(spacing: 24) {
                        PageIndicator(currentPage: currentPage, totalPages: pages.count)

                        if currentPage == pages.count - 1 {
                            CosmicButton(title: "Get Started") {
                                showBirthDataInput = true
                            }
                            .padding(.horizontal, 32)
                        } else {
                            CosmicButton(title: "Next") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                            .padding(.horizontal, 32)
                        }

                        if currentPage < pages.count - 1 {
                            Button("Skip") {
                                showBirthDataInput = true
                            }
                            .font(CosmicTypography.subheadline)
                            .foregroundColor(CosmicColors.textSecondary)
                            .accessibilityLabel("Skip introduction")
                            .accessibilityHint("Skips remaining introduction pages and goes to birth data input")
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationDestination(isPresented: $showBirthDataInput) {
                BirthDataInputView()
            }
        }
    }
}

struct WelcomePageView: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(CosmicColors.cosmicGradient)
                    .frame(width: 160, height: 160)

                Image(systemName: icon)
                    .font(.system(size: 64))
                    .foregroundColor(CosmicColors.cosmicGold)
            }
            .accessibilityHidden(true)

            VStack(spacing: 16) {
                Text(title)
                    .font(CosmicTypography.title1)
                    .foregroundColor(CosmicColors.text)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(CosmicTypography.body)
                    .foregroundColor(CosmicColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? CosmicColors.primary : CosmicColors.primary.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Page \(currentPage + 1) of \(totalPages)")
    }
}

#Preview {
    WelcomeView()
}
