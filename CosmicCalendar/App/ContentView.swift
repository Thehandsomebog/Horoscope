import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @Query private var users: [User]

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding && !users.isEmpty {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
        .modelContainer(for: User.self, inMemory: true)
}
