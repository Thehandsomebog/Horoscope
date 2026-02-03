import XCTest
@testable import CosmicCalendar

final class CrashReportingServiceTests: XCTestCase {

    // MARK: - Mock Reporter

    private class MockCrashReporter: CrashReporter {
        var initializeCalled = false
        var recordedErrors: [(Error, [String: Any]?)] = []
        var currentUserId: String?
        var customValues: [String: Any] = [:]
        var logMessages: [String] = []

        func initialize() {
            initializeCalled = true
        }

        func recordError(_ error: Error, userInfo: [String: Any]?) {
            recordedErrors.append((error, userInfo))
        }

        func setUserId(_ userId: String?) {
            currentUserId = userId
        }

        func setCustomValue(_ value: Any, forKey key: String) {
            customValues[key] = value
        }

        func log(_ message: String) {
            logMessages.append(message)
        }
    }

    // MARK: - CrashReportingError Tests

    func testEphemerisCalculationFailedErrorDescription() {
        let date = Date()
        let error = CrashReportingError.ephemerisCalculationFailed(planet: "Mercury", date: date)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("Mercury"))
        XCTAssertTrue(error.errorDescription!.contains("Ephemeris"))
    }

    func testScoreCalculationFailedErrorDescription() {
        let error = CrashReportingError.scoreCalculationFailed(domain: "career", reason: "invalid data")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("career"))
        XCTAssertTrue(error.errorDescription!.contains("invalid data"))
    }

    func testLocationSearchFailedErrorDescription() {
        let error = CrashReportingError.locationSearchFailed(query: "New York", underlyingError: nil)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("New York"))
    }

    func testNotificationSchedulingFailedErrorDescription() {
        let error = CrashReportingError.notificationSchedulingFailed(type: "morning_briefing", underlyingError: nil)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("morning_briefing"))
    }

    func testDataCorruptionErrorDescription() {
        let error = CrashReportingError.dataCorruption(model: "User", details: "missing birth date")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("User"))
        XCTAssertTrue(error.errorDescription!.contains("missing birth date"))
    }

    func testNetworkErrorWithStatusCode() {
        let error = CrashReportingError.networkError(endpoint: "/api/data", statusCode: 404)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("/api/data"))
        XCTAssertTrue(error.errorDescription!.contains("404"))
    }

    func testNetworkErrorWithoutStatusCode() {
        let error = CrashReportingError.networkError(endpoint: "/api/data", statusCode: nil)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("/api/data"))
        XCTAssertFalse(error.errorDescription!.contains("HTTP"))
    }

    func testUnexpectedStateErrorDescription() {
        let error = CrashReportingError.unexpectedState(context: "onboarding", details: "no user found")

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("onboarding"))
        XCTAssertTrue(error.errorDescription!.contains("no user found"))
    }

    // MARK: - CrashReporter Protocol Tests

    func testMockReporterRecordsErrors() {
        let reporter = MockCrashReporter()
        let error = NSError(domain: "TestDomain", code: 100, userInfo: nil)

        reporter.recordError(error, userInfo: ["key": "value"])

        XCTAssertEqual(reporter.recordedErrors.count, 1)
        XCTAssertEqual((reporter.recordedErrors[0].0 as NSError).domain, "TestDomain")
        XCTAssertEqual((reporter.recordedErrors[0].0 as NSError).code, 100)
        XCTAssertEqual(reporter.recordedErrors[0].1?["key"] as? String, "value")
    }

    func testMockReporterSetsUserId() {
        let reporter = MockCrashReporter()

        reporter.setUserId("user123")
        XCTAssertEqual(reporter.currentUserId, "user123")

        reporter.setUserId(nil)
        XCTAssertNil(reporter.currentUserId)
    }

    func testMockReporterSetsCustomValues() {
        let reporter = MockCrashReporter()

        reporter.setCustomValue("iOS 17", forKey: "os_version")
        reporter.setCustomValue(true, forKey: "has_birth_time")
        reporter.setCustomValue(42, forKey: "sessions_count")

        XCTAssertEqual(reporter.customValues["os_version"] as? String, "iOS 17")
        XCTAssertEqual(reporter.customValues["has_birth_time"] as? Bool, true)
        XCTAssertEqual(reporter.customValues["sessions_count"] as? Int, 42)
    }

    func testMockReporterLogsMessages() {
        let reporter = MockCrashReporter()

        reporter.log("User opened app")
        reporter.log("Navigated to calendar")
        reporter.log("Selected date")

        XCTAssertEqual(reporter.logMessages.count, 3)
        XCTAssertEqual(reporter.logMessages[0], "User opened app")
        XCTAssertEqual(reporter.logMessages[1], "Navigated to calendar")
        XCTAssertEqual(reporter.logMessages[2], "Selected date")
    }

    func testMockReporterInitializes() {
        let reporter = MockCrashReporter()

        XCTAssertFalse(reporter.initializeCalled)
        reporter.initialize()
        XCTAssertTrue(reporter.initializeCalled)
    }

    // MARK: - ConsoleCrashReporter Tests

    func testConsoleCrashReporterCanBeInstantiated() {
        let reporter = ConsoleCrashReporter()
        XCTAssertNotNil(reporter)
    }

    func testConsoleCrashReporterInitializes() {
        let reporter = ConsoleCrashReporter()
        reporter.initialize()
        // Should not throw
    }

    func testConsoleCrashReporterRecordsErrors() {
        let reporter = ConsoleCrashReporter()
        reporter.initialize()

        let error = NSError(domain: "TestDomain", code: 100, userInfo: nil)
        reporter.recordError(error, userInfo: nil)
        // Should not throw, logs to console
    }

    func testConsoleCrashReporterHandlesNilUserInfo() {
        let reporter = ConsoleCrashReporter()
        reporter.initialize()

        let error = NSError(domain: "TestDomain", code: 100, userInfo: nil)
        reporter.recordError(error, userInfo: nil)
        // Should not throw
    }

    func testConsoleCrashReporterHandlesEmptyUserInfo() {
        let reporter = ConsoleCrashReporter()
        reporter.initialize()

        let error = NSError(domain: "TestDomain", code: 100, userInfo: nil)
        reporter.recordError(error, userInfo: [:])
        // Should not throw
    }

    func testConsoleCrashReporterSetsAndClearsUserId() {
        let reporter = ConsoleCrashReporter()
        reporter.initialize()

        reporter.setUserId("user123")
        reporter.setUserId(nil)
        // Should not throw
    }

    func testConsoleCrashReporterSetsCustomValues() {
        let reporter = ConsoleCrashReporter()
        reporter.initialize()

        reporter.setCustomValue("test_value", forKey: "test_key")
        // Should not throw
    }

    func testConsoleCrashReporterLogsBreadcrumbs() {
        let reporter = ConsoleCrashReporter()
        reporter.initialize()

        for i in 0..<150 {
            reporter.log("Breadcrumb \(i)")
        }
        // Should not throw, and should handle breadcrumb limit internally
    }

    // MARK: - CrashReportingService Singleton Tests

    func testCrashReportingServiceIsSingleton() {
        let instance1 = CrashReportingService.shared
        let instance2 = CrashReportingService.shared

        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Integration Tests

    func testCrashReportingErrorCanBeRecorded() {
        let reporter = MockCrashReporter()
        reporter.initialize()

        let error = CrashReportingError.scoreCalculationFailed(domain: "relationships", reason: "test")
        reporter.recordError(error, userInfo: nil)

        XCTAssertEqual(reporter.recordedErrors.count, 1)
    }

    func testMultipleErrorsCanBeRecorded() {
        let reporter = MockCrashReporter()
        reporter.initialize()

        for i in 0..<10 {
            let error = NSError(domain: "TestDomain", code: i, userInfo: nil)
            reporter.recordError(error, userInfo: nil)
        }

        XCTAssertEqual(reporter.recordedErrors.count, 10)
    }

    func testUserInfoIsPreservedInRecordedErrors() {
        let reporter = MockCrashReporter()
        reporter.initialize()

        let userInfo: [String: Any] = [
            "planet": "Mercury",
            "longitude": 125.5,
            "is_retrograde": true
        ]
        let error = NSError(domain: "Ephemeris", code: 1, userInfo: nil)
        reporter.recordError(error, userInfo: userInfo)

        XCTAssertEqual(reporter.recordedErrors[0].1?["planet"] as? String, "Mercury")
        XCTAssertEqual(reporter.recordedErrors[0].1?["longitude"] as? Double, 125.5)
        XCTAssertEqual(reporter.recordedErrors[0].1?["is_retrograde"] as? Bool, true)
    }

    // MARK: - Edge Cases

    func testEmptyStringUserIdIsHandled() {
        let reporter = MockCrashReporter()
        reporter.setUserId("")

        XCTAssertEqual(reporter.currentUserId, "")
    }

    func testVeryLongLogMessageIsHandled() {
        let reporter = MockCrashReporter()
        let longMessage = String(repeating: "x", count: 10000)

        reporter.log(longMessage)

        XCTAssertEqual(reporter.logMessages.count, 1)
        XCTAssertEqual(reporter.logMessages[0].count, 10000)
    }

    func testSpecialCharactersInCustomValues() {
        let reporter = MockCrashReporter()

        reporter.setCustomValue("Hello\nWorld\tTab", forKey: "special_chars")
        reporter.setCustomValue("", forKey: "empty_key")

        XCTAssertEqual(reporter.customValues["special_chars"] as? String, "Hello\nWorld\tTab")
        XCTAssertEqual(reporter.customValues["empty_key"] as? String, "")
    }

    func testUnicodeInErrorDescription() {
        let error = CrashReportingError.locationSearchFailed(query: "东京", underlyingError: nil)

        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("东京"))
    }
}
