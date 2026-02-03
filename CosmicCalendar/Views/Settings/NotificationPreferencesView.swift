import SwiftUI

struct NotificationPreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationService = NotificationService.shared

    @State private var showTimePicker: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicColors.background
                    .ignoresSafeArea()

                List {
                    permissionSection

                    if notificationService.isAuthorized {
                        morningBriefingSection

                        alertsSection
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(CosmicColors.primary)
                    .accessibilityLabel("Done")
                    .accessibilityHint("Closes notification preferences")
                }
            }
        }
    }

    private var permissionSection: some View {
        Section {
            if notificationService.isAuthorized {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(CosmicColors.good)
                        .accessibilityHidden(true)

                    Text("Notifications Enabled")
                        .font(CosmicTypography.body)
                        .foregroundColor(CosmicColors.text)

                    Spacer()
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Enable notifications to receive cosmic alerts and daily briefings.")
                        .font(CosmicTypography.subheadline)
                        .foregroundColor(CosmicColors.textSecondary)

                    Button {
                        Task {
                            await notificationService.requestAuthorization()
                        }
                    } label: {
                        Text("Enable Notifications")
                            .font(CosmicTypography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(CosmicColors.primary)
                            )
                    }
                    .accessibilityLabel("Enable Notifications")
                    .accessibilityHint("Requests permission to send you notifications")
                }
            }
        } header: {
            Text("Permission")
                .foregroundColor(CosmicColors.textSecondary)
        }
        .listRowBackground(Color.white)
    }

    private var morningBriefingSection: some View {
        Section {
            Toggle(isOn: $notificationService.morningBriefingEnabled) {
                HStack {
                    Image(systemName: "sun.horizon.fill")
                        .foregroundColor(CosmicColors.cosmicGold)
                        .frame(width: 28)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Morning Cosmic Briefing")
                            .font(CosmicTypography.body)
                            .foregroundColor(CosmicColors.text)

                        Text("Daily notification with your cosmic outlook")
                            .font(CosmicTypography.caption)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                }
            }
            .tint(CosmicColors.primary)
            .accessibilityLabel("Morning Cosmic Briefing")
            .accessibilityHint("Toggles daily notification with your cosmic outlook")
            .listRowBackground(Color.white)

            if notificationService.morningBriefingEnabled {
                Button {
                    showTimePicker.toggle()
                } label: {
                    HStack {
                        Text("Delivery Time")
                            .font(CosmicTypography.body)
                            .foregroundColor(CosmicColors.text)

                        Spacer()

                        Text(formattedTime(notificationService.morningBriefingTime))
                            .font(CosmicTypography.subheadline)
                            .foregroundColor(CosmicColors.accent)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(CosmicColors.text.opacity(0.3))
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityLabel("Delivery Time: \(formattedTime(notificationService.morningBriefingTime))")
                .accessibilityHint("Opens time picker to change notification time")
                .listRowBackground(Color.white)

                if showTimePicker {
                    DatePicker(
                        "Time",
                        selection: $notificationService.morningBriefingTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .accessibilityLabel("Select notification time")
                    .listRowBackground(Color.white)
                }
            }
        } header: {
            Text("Daily Briefing")
                .foregroundColor(CosmicColors.textSecondary)
        }
    }

    private var alertsSection: some View {
        Section {
            Toggle(isOn: $notificationService.retrogradeAlertsEnabled) {
                HStack {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .foregroundColor(CosmicColors.challenging)
                        .frame(width: 28)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Retrograde Alerts")
                            .font(CosmicTypography.body)
                            .foregroundColor(CosmicColors.text)

                        Text("When Mercury, Venus, or Mars go retrograde")
                            .font(CosmicTypography.caption)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                }
            }
            .tint(CosmicColors.primary)
            .accessibilityLabel("Retrograde Alerts")
            .accessibilityHint("Toggles notifications when Mercury, Venus, or Mars go retrograde")
            .listRowBackground(Color.white)

            Toggle(isOn: $notificationService.moonPhaseAlertsEnabled) {
                HStack {
                    Image(systemName: "moon.circle.fill")
                        .foregroundColor(CosmicColors.accent)
                        .frame(width: 28)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Moon Phase Alerts")
                            .font(CosmicTypography.body)
                            .foregroundColor(CosmicColors.text)

                        Text("Full moons and new moons")
                            .font(CosmicTypography.caption)
                            .foregroundColor(CosmicColors.textSecondary)
                    }
                }
            }
            .tint(CosmicColors.primary)
            .accessibilityLabel("Moon Phase Alerts")
            .accessibilityHint("Toggles notifications for full moons and new moons")
            .listRowBackground(Color.white)
        } header: {
            Text("Cosmic Events")
                .foregroundColor(CosmicColors.textSecondary)
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NotificationPreferencesView()
}
