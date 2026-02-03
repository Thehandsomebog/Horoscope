import Foundation
import SwiftData
import CoreLocation

@Model
final class User {
    var id: UUID
    var name: String
    var birthDate: Date
    var birthTime: Date?
    var birthLocationName: String
    var birthLatitude: Double
    var birthLongitude: Double
    var birthTimezone: String
    var createdAt: Date
    var updatedAt: Date

    @Transient
    var birthLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: birthLatitude, longitude: birthLongitude)
    }

    @Transient
    var hasBirthTime: Bool {
        birthTime != nil
    }

    init(
        name: String,
        birthDate: Date,
        birthTime: Date? = nil,
        birthLocationName: String,
        birthLatitude: Double,
        birthLongitude: Double,
        birthTimezone: String = TimeZone.current.identifier
    ) {
        self.id = UUID()
        self.name = name
        self.birthDate = birthDate
        self.birthTime = birthTime
        self.birthLocationName = birthLocationName
        self.birthLatitude = birthLatitude
        self.birthLongitude = birthLongitude
        self.birthTimezone = birthTimezone
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var fullBirthDateTime: Date {
        guard let birthTime = birthTime else { return birthDate }

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: birthDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: birthTime)

        var combined = DateComponents()
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        combined.timeZone = TimeZone(identifier: birthTimezone)

        return calendar.date(from: combined) ?? birthDate
    }

    var julianDay: Double {
        let date = fullBirthDateTime
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)

        let year = Double(components.year ?? 2000)
        let month = Double(components.month ?? 1)
        let day = Double(components.day ?? 1)
        let hour = Double(components.hour ?? 12)
        let minute = Double(components.minute ?? 0)

        let decimalDay = day + (hour + minute / 60.0) / 24.0

        var y = year
        var m = month
        if m <= 2 {
            y -= 1
            m += 12
        }

        let a = floor(y / 100.0)
        let b = 2 - a + floor(a / 4.0)

        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + decimalDay + b - 1524.5
    }
}
