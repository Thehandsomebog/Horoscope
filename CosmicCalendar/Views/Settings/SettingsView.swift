import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @Query private var users: [User]

    @State private var showNotificationPreferences: Bool = false
    @State private var showEditProfile: Bool = false
    @State private var showResetConfirmation: Bool = false

    private var user: User? { users.first }

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicColors.background
                    .ignoresSafeArea()

                List {
                    if let user = user {
                        profileSection(user: user)
                    }

                    notificationsSection

                    birthChartSection

                    aboutSection

                    dangerZoneSection
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showNotificationPreferences) {
                NotificationPreferencesView()
            }
            .confirmationDialog(
                "Reset App Data",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset Everything", role: .destructive) {
                    resetAppData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete your birth data and all settings. This action cannot be undone.")
            }
        }
    }

    private func profileSection(user: User) -> some View {
        Section {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(CosmicColors.cosmicGradient)
                        .frame(width: 60, height: 60)

                    Text(user.name.prefix(1).uppercased())
                        .font(CosmicTypography.title2)
                        .foregroundColor(CosmicColors.cosmicGold)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(user.name)
                        .font(CosmicTypography.headline)
                        .foregroundColor(CosmicColors.text)

                    let birthChart = EphemerisService.shared.calculateBirthChart(for: user)
                    HStack(spacing: 8) {
                        Text(birthChart.sunSign.symbol)
                        Text(birthChart.sunSign.rawValue)
                            .font(CosmicTypography.subheadline)
                            .foregroundColor(CosmicColors.text.opacity(0.7))
                    }
                }

                Spacer()
            }
            .padding(.vertical, 8)
            .listRowBackground(Color.white)
        }
    }

    private var notificationsSection: some View {
        Section {
            Button {
                showNotificationPreferences = true
            } label: {
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(CosmicColors.accent)
                        .frame(width: 28)

                    Text("Notification Preferences")
                        .font(CosmicTypography.body)
                        .foregroundColor(CosmicColors.text)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(CosmicColors.text.opacity(0.3))
                }
            }
            .listRowBackground(Color.white)
        } header: {
            Text("Notifications")
                .foregroundColor(CosmicColors.text.opacity(0.6))
        }
    }

    private var birthChartSection: some View {
        Section {
            if let user = user {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(label: "Birth Date", value: formattedDate(user.birthDate))
                    if let time = user.birthTime {
                        InfoRow(label: "Birth Time", value: formattedTime(time))
                    }
                    InfoRow(label: "Birth Location", value: user.birthLocationName)
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Birth Data")
                .foregroundColor(CosmicColors.text.opacity(0.6))
        }
        .listRowBackground(Color.white)
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                    .font(CosmicTypography.body)
                    .foregroundColor(CosmicColors.text)

                Spacer()

                Text("1.0.0")
                    .font(CosmicTypography.subheadline)
                    .foregroundColor(CosmicColors.text.opacity(0.6))
            }
            .listRowBackground(Color.white)

            Link(destination: URL(string: "https://example.com/privacy")!) {
                HStack {
                    Text("Privacy Policy")
                        .font(CosmicTypography.body)
                        .foregroundColor(CosmicColors.text)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(CosmicColors.accent)
                }
            }
            .listRowBackground(Color.white)

            Link(destination: URL(string: "https://example.com/terms")!) {
                HStack {
                    Text("Terms of Service")
                        .font(CosmicTypography.body)
                        .foregroundColor(CosmicColors.text)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(CosmicColors.accent)
                }
            }
            .listRowBackground(Color.white)
        } header: {
            Text("About")
                .foregroundColor(CosmicColors.text.opacity(0.6))
        }
    }

    private var dangerZoneSection: some View {
        Section {
            Button(role: .destructive) {
                showResetConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .frame(width: 28)

                    Text("Reset All Data")
                        .font(CosmicTypography.body)
                }
            }
            .listRowBackground(Color.white)
        } header: {
            Text("Danger Zone")
                .foregroundColor(CosmicColors.text.opacity(0.6))
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func resetAppData() {
        for user in users {
            modelContext.delete(user)
        }

        try? modelContext.save()

        NotificationService.shared.cancelAllNotifications()

        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "morningBriefingEnabled")
        UserDefaults.standard.removeObject(forKey: "retrogradeAlertsEnabled")
        UserDefaults.standard.removeObject(forKey: "moonPhaseAlertsEnabled")

        appState.resetOnboarding()
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(CosmicTypography.subheadline)
                .foregroundColor(CosmicColors.text.opacity(0.6))

            Spacer()

            Text(value)
                .font(CosmicTypography.body)
                .foregroundColor(CosmicColors.text)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .modelContainer(for: User.self, inMemory: true)
}
