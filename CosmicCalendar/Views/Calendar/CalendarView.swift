import SwiftUI
import SwiftData

struct CalendarView: View {
    @Query private var users: [User]
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var cosmicDays: [Date: CosmicDay] = [:]
    @State private var selectedCosmicDay: CosmicDay?
    @State private var showDayDetail: Bool = false

    private let calendar = Calendar.current
    private let scoreCalculator = CosmicScoreCalculator.shared
    private let ephemeris = EphemerisService.shared

    private var user: User? { users.first }

    var body: some View {
        NavigationStack {
            ZStack {
                CosmicColors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        monthNavigator

                        weekdayHeaders

                        calendarGrid

                        if let day = selectedCosmicDay {
                            selectedDayCard(day: day)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Cosmic Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadMonthData()
            }
            .onChange(of: currentMonth) { _, _ in
                loadMonthData()
            }
            .sheet(isPresented: $showDayDetail) {
                if let day = selectedCosmicDay {
                    DayDetailView(cosmicDay: day)
                }
            }
        }
    }

    private var monthNavigator: some View {
        HStack {
            Button {
                withAnimation {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(CosmicColors.primary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Previous month")

            Spacer()

            Text(monthYearString(from: currentMonth))
                .font(CosmicTypography.title2)
                .foregroundColor(CosmicColors.text)
                .accessibilityAddTraits(.isHeader)

            Spacer()

            Button {
                withAnimation {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(CosmicColors.primary)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Next month")
        }
        .padding(.horizontal, 8)
    }

    private var weekdayHeaders: some View {
        HStack(spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day.prefix(2).uppercased())
                    .font(CosmicTypography.caption)
                    .foregroundColor(CosmicColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .accessibilityHidden(true) // Days are read with each cell
            }
        }
    }

    private var calendarGrid: some View {
        let days = daysInMonth()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    CalendarDayCell(
                        date: date,
                        cosmicDay: cosmicDays[normalizedDate(date)],
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date)
                    )
                    .onTapGesture {
                        selectDate(date)
                    }
                } else {
                    Color.clear
                        .frame(height: 52)
                }
            }
        }
    }

    private func selectedDayCard(day: CosmicDay) -> some View {
        CosmicCard {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedDate(day.date))
                            .font(CosmicTypography.headline)
                            .foregroundColor(CosmicColors.text)

                        Text(day.scoreCategory.description)
                            .font(CosmicTypography.caption)
                            .foregroundColor(CosmicColors.textSecondary)
                    }

                    Spacer()

                    ScoreBadge(score: day.overallScore, size: .medium)
                }

                HStack(spacing: 20) {
                    MiniDomainScore(domain: .relationships, score: day.relationshipScore)
                    MiniDomainScore(domain: .career, score: day.careerScore)
                    MiniDomainScore(domain: .health, score: day.healthScore)
                }

                Button {
                    showDayDetail = true
                } label: {
                    HStack {
                        Text("View Full Report")
                            .font(CosmicTypography.subheadline)
                        Image(systemName: "arrow.right")
                            .accessibilityHidden(true)
                    }
                    .foregroundColor(CosmicColors.primary)
                }
                .accessibilityHint("Opens detailed cosmic report for this day")
            }
        }
    }

    private func loadMonthData() {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let year = components.year, let month = components.month else { return }

        var birthChart: BirthChart? = nil
        if let user = user {
            birthChart = ephemeris.calculateBirthChart(for: user)
        }

        cosmicDays = scoreCalculator.calculateScoresForMonth(year: year, month: month, birthChart: birthChart)

        if let todayDay = cosmicDays[normalizedDate(Date())] {
            selectedCosmicDay = todayDay
        } else if let firstDay = cosmicDays.values.first {
            selectedCosmicDay = firstDay
        }
    }

    private func selectDate(_ date: Date) {
        selectedDate = date
        selectedCosmicDay = cosmicDays[normalizedDate(date)]
    }

    private func normalizedDate(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        var days: [Date?] = []
        let firstDayOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let prefixDays = firstWeekday - calendar.firstWeekday
        let normalizedPrefix = prefixDays < 0 ? prefixDays + 7 : prefixDays

        for _ in 0..<normalizedPrefix {
            days.append(nil)
        }

        var currentDate = firstDayOfMonth
        while currentDate < monthInterval.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return days
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }
}

struct CalendarDayCell: View {
    let date: Date
    let cosmicDay: CosmicDay?
    let isSelected: Bool
    let isToday: Bool

    private let calendar = Calendar.current

    private var scoreCategory: String {
        guard let day = cosmicDay else { return "" }
        switch day.overallScore {
        case 8.5...10: return ", excellent cosmic energy"
        case 7...8.49: return ", good cosmic energy"
        case 5...6.99: return ", neutral cosmic energy"
        case 3...4.99: return ", challenging cosmic energy"
        default: return ", difficult cosmic energy"
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(CosmicTypography.body)
                .foregroundColor(textColor)

            if let day = cosmicDay {
                Circle()
                    .fill(CosmicColors.scoreColor(for: day.overallScore))
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true) // Score is announced with cell
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isToday ? CosmicColors.primary : .clear, lineWidth: 2)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(dateFormatter.string(from: date))\(isToday ? ", today" : "")\(scoreCategory)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint("Double tap to view cosmic report")
    }

    private var textColor: Color {
        if isSelected {
            return .white
        }
        return CosmicColors.text
    }

    private var backgroundColor: Color {
        if isSelected {
            return CosmicColors.primary
        }
        return Color.white.opacity(0.5)
    }
}

struct MiniDomainScore: View {
    let domain: LifeDomain
    let score: Double

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: domain.icon)
                .font(.system(size: 16))
                .foregroundColor(CosmicColors.scoreColor(for: score))
                .accessibilityHidden(true)

            Text(String(format: "%.1f", score))
                .font(CosmicTypography.caption)
                .foregroundColor(CosmicColors.text)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(domain.rawValue): \(String(format: "%.1f", score))")
    }
}

#Preview {
    CalendarView()
        .modelContainer(for: User.self, inMemory: true)
}
