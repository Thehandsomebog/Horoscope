import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            TodayView()
                .tabItem {
                    Label(AppState.Tab.today.title, systemImage: AppState.Tab.today.icon)
                }
                .tag(AppState.Tab.today)

            CalendarView()
                .tabItem {
                    Label(AppState.Tab.calendar.title, systemImage: AppState.Tab.calendar.icon)
                }
                .tag(AppState.Tab.calendar)

            SettingsView()
                .tabItem {
                    Label(AppState.Tab.settings.title, systemImage: AppState.Tab.settings.icon)
                }
                .tag(AppState.Tab.settings)
        }
        .tint(CosmicColors.primary)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppState())
        .modelContainer(for: User.self, inMemory: true)
}
