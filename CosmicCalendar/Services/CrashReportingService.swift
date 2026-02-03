import Foundation
import os.log

/// Protocol for crash reporting backends.
/// Implement this protocol to add support for Firebase Crashlytics, Sentry, or other providers.
protocol CrashReporter {
    /// Initialize the crash reporting backend
    func initialize()

    /// Record a non-fatal error
    func recordError(_ error: Error, userInfo: [String: Any]?)

    /// Set a user identifier for crash reports
    func setUserId(_ userId: String?)

    /// Set a custom key-value pair for crash reports
    func setCustomValue(_ value: Any, forKey key: String)

    /// Log a message that will be included in crash reports
    func log(_ message: String)
}

/// Application-specific error types for crash reporting
enum CrashReportingError: LocalizedError {
    case ephemerisCalculationFailed(planet: String, date: Date)
    case scoreCalculationFailed(domain: String, reason: String)
    case locationSearchFailed(query: String, underlyingError: Error?)
    case notificationSchedulingFailed(type: String, underlyingError: Error?)
    case dataCorruption(model: String, details: String)
    case networkError(endpoint: String, statusCode: Int?)
    case unexpectedState(context: String, details: String)

    var errorDescription: String? {
        switch self {
        case .ephemerisCalculationFailed(let planet, let date):
            return "Ephemeris calculation failed for \(planet) on \(date)"
        case .scoreCalculationFailed(let domain, let reason):
            return "Score calculation failed for \(domain): \(reason)"
        case .locationSearchFailed(let query, _):
            return "Location search failed for query: \(query)"
        case .notificationSchedulingFailed(let type, _):
            return "Notification scheduling failed for type: \(type)"
        case .dataCorruption(let model, let details):
            return "Data corruption detected in \(model): \(details)"
        case .networkError(let endpoint, let statusCode):
            if let code = statusCode {
                return "Network error for \(endpoint): HTTP \(code)"
            }
            return "Network error for \(endpoint)"
        case .unexpectedState(let context, let details):
            return "Unexpected state in \(context): \(details)"
        }
    }
}

/// Central service for crash and error reporting.
/// Follows the singleton pattern consistent with other services in the app.
final class CrashReportingService: ObservableObject {
    static let shared = CrashReportingService()

    private var reporter: CrashReporter?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmicCalendar", category: "CrashReporting")

    /// Indicates whether a crash reporter backend is configured
    @Published private(set) var isConfigured: Bool = false

    private init() {
        // Use console reporter by default for development
        #if DEBUG
        configure(with: ConsoleCrashReporter())
        #endif
    }

    /// Configure the crash reporting service with a specific backend.
    /// Call this early in the app lifecycle (e.g., in App.init or application:didFinishLaunching).
    ///
    /// Example with Firebase Crashlytics:
    /// ```
    /// CrashReportingService.shared.configure(with: FirebaseCrashlyticsReporter())
    /// ```
    func configure(with reporter: CrashReporter) {
        self.reporter = reporter
        reporter.initialize()
        isConfigured = true
        log("Crash reporting configured with \(type(of: reporter))")
    }

    /// Record a non-fatal error.
    /// Use this for errors that don't crash the app but should be tracked.
    func recordError(_ error: Error, userInfo: [String: Any]? = nil) {
        logger.error("Recording error: \(error.localizedDescription)")
        reporter?.recordError(error, userInfo: userInfo)
    }

    /// Record a CrashReportingError with additional context.
    func recordError(_ error: CrashReportingError, userInfo: [String: Any]? = nil) {
        var info = userInfo ?? [:]
        info["error_type"] = String(describing: error)
        recordError(error as Error, userInfo: info)
    }

    /// Set the user identifier for crash reports.
    /// This helps correlate crashes with specific users.
    /// Pass nil to clear the user ID.
    func setUserId(_ userId: String?) {
        reporter?.setUserId(userId)
        if let userId = userId {
            logger.info("User ID set for crash reporting")
            log("User ID configured: \(userId.prefix(8))...")
        } else {
            logger.info("User ID cleared for crash reporting")
        }
    }

    /// Set a custom key-value pair for crash reports.
    /// Use this to add context that helps debug crashes.
    func setCustomValue(_ value: Any, forKey key: String) {
        reporter?.setCustomValue(value, forKey: key)
    }

    /// Log a message that will be included in crash reports.
    /// Use this for breadcrumbs that help understand the app state before a crash.
    func log(_ message: String) {
        logger.debug("\(message)")
        reporter?.log(message)
    }

    /// Record an error that occurred during ephemeris calculations.
    func recordEphemerisError(planet: String, date: Date, underlyingError: Error? = nil) {
        let error = CrashReportingError.ephemerisCalculationFailed(planet: planet, date: date)
        var userInfo: [String: Any] = [
            "planet": planet,
            "date": ISO8601DateFormatter().string(from: date)
        ]
        if let underlying = underlyingError {
            userInfo["underlying_error"] = underlying.localizedDescription
        }
        recordError(error, userInfo: userInfo)
    }

    /// Record an error that occurred during score calculations.
    func recordScoreError(domain: String, reason: String) {
        let error = CrashReportingError.scoreCalculationFailed(domain: domain, reason: reason)
        recordError(error, userInfo: ["domain": domain, "reason": reason])
    }

    /// Record an error that occurred during location search.
    func recordLocationError(query: String, underlyingError: Error) {
        let error = CrashReportingError.locationSearchFailed(query: query, underlyingError: underlyingError)
        recordError(error, userInfo: [
            "query": query,
            "underlying_error": underlyingError.localizedDescription
        ])
    }
}

// MARK: - Console Crash Reporter (Development)

/// A crash reporter that logs to the console.
/// Use this for development and testing.
final class ConsoleCrashReporter: CrashReporter {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "CosmicCalendar", category: "ConsoleCrashReporter")
    private var userId: String?
    private var customValues: [String: Any] = [:]
    private var breadcrumbs: [String] = []
    private let maxBreadcrumbs = 100

    func initialize() {
        logger.info("Console crash reporter initialized (development mode)")
    }

    func recordError(_ error: Error, userInfo: [String: Any]?) {
        var message = "NON-FATAL ERROR: \(error.localizedDescription)"
        if let info = userInfo, !info.isEmpty {
            message += "\nUser Info: \(info)"
        }
        if let userId = userId {
            message += "\nUser ID: \(userId)"
        }
        if !customValues.isEmpty {
            message += "\nCustom Values: \(customValues)"
        }
        if !breadcrumbs.isEmpty {
            let recentBreadcrumbs = breadcrumbs.suffix(10)
            message += "\nRecent breadcrumbs: \(recentBreadcrumbs.joined(separator: " -> "))"
        }
        logger.error("\(message)")
    }

    func setUserId(_ userId: String?) {
        self.userId = userId
        if let id = userId {
            logger.debug("User ID set: \(id)")
        } else {
            logger.debug("User ID cleared")
        }
    }

    func setCustomValue(_ value: Any, forKey key: String) {
        customValues[key] = value
        logger.debug("Custom value set: \(key) = \(String(describing: value))")
    }

    func log(_ message: String) {
        breadcrumbs.append(message)
        if breadcrumbs.count > maxBreadcrumbs {
            breadcrumbs.removeFirst()
        }
        logger.debug("Breadcrumb: \(message)")
    }
}

// MARK: - Firebase Crashlytics Reporter (Production)

/*
 To enable Firebase Crashlytics:

 1. Create a Firebase project at https://console.firebase.google.com
 2. Add an iOS app to your project
 3. Download GoogleService-Info.plist and add it to the Xcode project
 4. Add Firebase SDK via Swift Package Manager:
    - File > Add Package Dependencies
    - URL: https://github.com/firebase/firebase-ios-sdk
    - Select FirebaseCrashlytics package
 5. Uncomment the FirebaseCrashlyticsReporter class below
 6. In CosmicCalendarApp.swift, configure the service:

    init() {
        CrashReportingService.shared.configure(with: FirebaseCrashlyticsReporter())
    }

 7. Add Run Script build phase for dSYM upload (see Firebase docs)
 */

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
import FirebaseCore

final class FirebaseCrashlyticsReporter: CrashReporter {
    func initialize() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    func recordError(_ error: Error, userInfo: [String: Any]?) {
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }

    func setUserId(_ userId: String?) {
        Crashlytics.crashlytics().setUserID(userId ?? "")
    }

    func setCustomValue(_ value: Any, forKey key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }

    func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
}
#endif
