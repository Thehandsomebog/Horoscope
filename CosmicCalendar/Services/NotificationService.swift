import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published var isAuthorized: Bool = false
    @Published var morningBriefingEnabled: Bool {
        didSet {
            UserDefaults.standard.set(morningBriefingEnabled, forKey: "morningBriefingEnabled")
            if morningBriefingEnabled {
                scheduleMorningBriefing()
            } else {
                cancelMorningBriefing()
            }
        }
    }

    @Published var retrogradeAlertsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(retrogradeAlertsEnabled, forKey: "retrogradeAlertsEnabled")
        }
    }

    @Published var moonPhaseAlertsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(moonPhaseAlertsEnabled, forKey: "moonPhaseAlertsEnabled")
        }
    }

    @Published var morningBriefingTime: Date {
        didSet {
            UserDefaults.standard.set(morningBriefingTime.timeIntervalSince1970, forKey: "morningBriefingTime")
            if morningBriefingEnabled {
                scheduleMorningBriefing()
            }
        }
    }

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        self.morningBriefingEnabled = UserDefaults.standard.bool(forKey: "morningBriefingEnabled")
        self.retrogradeAlertsEnabled = UserDefaults.standard.bool(forKey: "retrogradeAlertsEnabled")
        self.moonPhaseAlertsEnabled = UserDefaults.standard.bool(forKey: "moonPhaseAlertsEnabled")

        let savedTime = UserDefaults.standard.double(forKey: "morningBriefingTime")
        if savedTime > 0 {
            self.morningBriefingTime = Date(timeIntervalSince1970: savedTime)
        } else {
            var components = DateComponents()
            components.hour = 8
            components.minute = 0
            self.morningBriefingTime = Calendar.current.date(from: components) ?? Date()
        }

        checkAuthorizationStatus()
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleMorningBriefing() {
        cancelMorningBriefing()

        guard isAuthorized && morningBriefingEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your Cosmic Briefing"
        content.body = "Check today's cosmic weather and guidance"
        content.sound = .default
        content.categoryIdentifier = "MORNING_BRIEFING"

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: morningBriefingTime)

        var triggerComponents = DateComponents()
        triggerComponents.hour = components.hour
        triggerComponents.minute = components.minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "morning-briefing",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling morning briefing: \(error)")
            }
        }
    }

    func cancelMorningBriefing() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["morning-briefing"])
    }

    func scheduleRetrogradeAlert(planet: Planet, startDate: Date, isStart: Bool) {
        guard isAuthorized && retrogradeAlertsEnabled else { return }

        let content = UNMutableNotificationContent()
        if isStart {
            content.title = "\(planet.rawValue) Retrograde Begins"
            content.body = "Time to slow down and review. Tap to see how this affects you."
        } else {
            content.title = "\(planet.rawValue) Goes Direct"
            content.body = "The retrograde period ends. Forward motion resumes!"
        }
        content.sound = .default
        content.categoryIdentifier = "RETROGRADE_ALERT"

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: startDate)
        components.hour = 9
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = "\(planet.rawValue.lowercased())-retrograde-\(isStart ? "start" : "end")-\(startDate.timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling retrograde alert: \(error)")
            }
        }
    }

    func scheduleMoonPhaseAlert(phase: MoonPhase, date: Date) {
        guard isAuthorized && moonPhaseAlertsEnabled else { return }
        guard phase == .fullMoon || phase == .newMoon else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(phase.symbol) \(phase.rawValue) Tonight"
        content.body = phase == .fullMoon
            ? "Heightened emotions and intuition. Perfect for manifestation rituals."
            : "Set your intentions for the lunar cycle ahead."
        content.sound = .default
        content.categoryIdentifier = "MOON_PHASE_ALERT"

        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 18
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = "\(phase.rawValue.lowercased().replacingOccurrences(of: " ", with: "-"))-\(date.timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling moon phase alert: \(error)")
            }
        }
    }

    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}
