import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }

    @Published var selectedTab: Tab = .today
    @Published var isLoading: Bool = false

    enum Tab: Int, CaseIterable {
        case today = 0
        case calendar = 1
        case settings = 2

        var title: String {
            switch self {
            case .today: return "Today"
            case .calendar: return "Calendar"
            case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .today: return "sun.and.horizon"
            case .calendar: return "calendar"
            case .settings: return "gear"
            }
        }
    }

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }

    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }

    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}
