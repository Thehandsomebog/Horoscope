import SwiftUI
import SwiftData

struct BirthDataInputView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState

    @State private var name: String = ""
    @State private var birthDate: Date = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
    @State private var birthTime: Date = Calendar.current.date(from: DateComponents(hour: 12, minute: 0)) ?? Date()
    @State private var knowsBirthTime: Bool = false
    @State private var locationQuery: String = ""
    @State private var selectedLocation: LocationResult?

    @StateObject private var locationService = LocationService.shared

    @State private var showChartReveal: Bool = false
    @State private var isValidating: Bool = false

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedLocation != nil
    }

    var body: some View {
        ZStack {
            CosmicColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    headerSection

                    nameSection

                    birthDateSection

                    birthTimeSection

                    locationSection

                    Spacer(minLength: 40)

                    submitButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Your Birth Data")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showChartReveal) {
            if let location = selectedLocation {
                ChartRevealView(
                    name: name,
                    birthDate: birthDate,
                    birthTime: knowsBirthTime ? birthTime : nil,
                    location: location
                )
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 48))
                .foregroundColor(CosmicColors.cosmicGold)

            Text("Tell us about you")
                .font(CosmicTypography.title2)
                .foregroundColor(CosmicColors.text)

            Text("Your birth data helps us calculate your unique cosmic profile")
                .font(CosmicTypography.subheadline)
                .foregroundColor(CosmicColors.text.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 8)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Name")
                .font(CosmicTypography.headline)
                .foregroundColor(CosmicColors.text)

            CosmicTextField(placeholder: "Enter your name", text: $name, icon: "person")
        }
    }

    private var birthDateSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Birth Date")
                .font(CosmicTypography.headline)
                .foregroundColor(CosmicColors.text)

            DatePicker(
                "Birth Date",
                selection: $birthDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .tint(CosmicColors.primary)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
        }
    }

    private var birthTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Birth Time")
                    .font(CosmicTypography.headline)
                    .foregroundColor(CosmicColors.text)

                Spacer()

                Toggle("", isOn: $knowsBirthTime)
                    .tint(CosmicColors.primary)
                    .labelsHidden()
            }

            if knowsBirthTime {
                DatePicker(
                    "Time",
                    selection: $birthTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 100)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                )
            } else {
                Text("Birth time is optional but helps calculate your rising sign for more accurate readings.")
                    .font(CosmicTypography.caption)
                    .foregroundColor(CosmicColors.text.opacity(0.6))
            }
        }
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Birth Location")
                .font(CosmicTypography.headline)
                .foregroundColor(CosmicColors.text)

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Image(systemName: "mappin.circle")
                        .foregroundColor(CosmicColors.accent)
                        .frame(width: 24)

                    TextField("Search city or town", text: $locationQuery)
                        .font(CosmicTypography.body)
                        .foregroundColor(CosmicColors.text)
                        .onChange(of: locationQuery) { _, newValue in
                            locationService.searchLocations(query: newValue)
                        }

                    if locationService.isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CosmicColors.secondary)
                )

                if !locationService.searchResults.isEmpty && selectedLocation == nil {
                    VStack(spacing: 0) {
                        ForEach(locationService.searchResults) { result in
                            Button {
                                selectedLocation = result
                                locationQuery = result.name
                                locationService.clearSearch()
                            } label: {
                                HStack {
                                    Text(result.name)
                                        .font(CosmicTypography.body)
                                        .foregroundColor(CosmicColors.text)

                                    Spacer()

                                    Image(systemName: "arrow.right")
                                        .font(.caption)
                                        .foregroundColor(CosmicColors.accent)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }

                            Divider()
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    )
                }

                if let selected = selectedLocation {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(CosmicColors.good)

                        Text(selected.name)
                            .font(CosmicTypography.subheadline)
                            .foregroundColor(CosmicColors.text)

                        Spacer()

                        Button {
                            selectedLocation = nil
                            locationQuery = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(CosmicColors.text.opacity(0.5))
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }

    private var submitButton: some View {
        CosmicButton(title: "Calculate My Chart") {
            showChartReveal = true
        }
        .opacity(isFormValid ? 1.0 : 0.5)
        .disabled(!isFormValid)
    }
}

#Preview {
    NavigationStack {
        BirthDataInputView()
            .environmentObject(AppState())
            .modelContainer(for: User.self, inMemory: true)
    }
}
