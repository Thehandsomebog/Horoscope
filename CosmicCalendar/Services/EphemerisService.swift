import Foundation

class EphemerisService {
    static let shared = EphemerisService()

    private init() {}

    func calculatePlanetaryPositions(for date: Date) -> [PlanetaryPosition] {
        let julianDay = julianDayFromDate(date)
        var positions: [PlanetaryPosition] = []

        for planet in Planet.allCases {
            let position = calculatePlanetPosition(planet: planet, julianDay: julianDay)
            positions.append(position)
        }

        return positions
    }

    func calculatePlanetPosition(planet: Planet, julianDay: Double) -> PlanetaryPosition {
        return calculatePlanetPositionFallback(planet: planet, julianDay: julianDay)
    }

    private func calculatePlanetPositionFallback(planet: Planet, julianDay: Double) -> PlanetaryPosition {
        let baseLongitudes: [Planet: Double] = [
            .sun: 280.46,
            .moon: 218.32,
            .mercury: 252.25,
            .venus: 181.98,
            .mars: 355.45,
            .jupiter: 34.40,
            .saturn: 50.08,
            .uranus: 314.20,
            .neptune: 304.22,
            .pluto: 238.96
        ]

        let dailyMotion: [Planet: Double] = [
            .sun: 0.9856,
            .moon: 13.1764,
            .mercury: 1.3833,
            .venus: 1.2002,
            .mars: 0.5240,
            .jupiter: 0.0831,
            .saturn: 0.0335,
            .uranus: 0.0117,
            .neptune: 0.0060,
            .pluto: 0.0040
        ]

        let j2000 = 2451545.0
        let daysSinceJ2000 = julianDay - j2000

        let baseLong = baseLongitudes[planet] ?? 0.0
        let motion = dailyMotion[planet] ?? 0.0
        var longitude = baseLong + (motion * daysSinceJ2000)
        longitude = longitude.truncatingRemainder(dividingBy: 360.0)
        if longitude < 0 { longitude += 360.0 }

        let isRetrograde = simulateRetrograde(planet: planet, julianDay: julianDay)

        return PlanetaryPosition(
            planet: planet,
            longitude: longitude,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: isRetrograde ? -motion : motion,
            isRetrograde: isRetrograde
        )
    }

    private func simulateRetrograde(planet: Planet, julianDay: Double) -> Bool {
        guard planet.canBeRetrograde else { return false }

        let retrogradeData: [Planet: [(start: Double, end: Double)]] = [
            .mercury: [
                (2460330.0, 2460352.0),
                (2460430.0, 2460453.0),
                (2460530.0, 2460553.0),
                (2460633.0, 2460656.0)
            ],
            .venus: [
                (2460500.0, 2460542.0)
            ],
            .mars: [
                (2460620.0, 2460695.0)
            ],
            .jupiter: [
                (2460200.0, 2460320.0),
                (2460565.0, 2460685.0)
            ],
            .saturn: [
                (2460150.0, 2460290.0),
                (2460515.0, 2460655.0)
            ],
            .uranus: [
                (2460180.0, 2460330.0),
                (2460545.0, 2460695.0)
            ],
            .neptune: [
                (2460130.0, 2460290.0),
                (2460495.0, 2460655.0)
            ],
            .pluto: [
                (2460090.0, 2460270.0),
                (2460455.0, 2460635.0)
            ]
        ]

        guard let periods = retrogradeData[planet] else { return false }

        for period in periods {
            if julianDay >= period.start && julianDay <= period.end {
                return true
            }
        }

        return false
    }

    func calculateMoonPhase(for date: Date) -> MoonPhase {
        let positions = calculatePlanetaryPositions(for: date)

        guard let sunPosition = positions.first(where: { $0.planet == .sun }),
              let moonPosition = positions.first(where: { $0.planet == .moon }) else {
            return .newMoon
        }

        var elongation = moonPosition.longitude - sunPosition.longitude
        if elongation < 0 { elongation += 360.0 }

        let illumination = (1.0 - cos(elongation * .pi / 180.0)) / 2.0
        let isWaxing = elongation < 180.0

        return MoonPhase.from(illumination: illumination, isWaxing: isWaxing)
    }

    func calculateAspects(between positions1: [PlanetaryPosition], and positions2: [PlanetaryPosition]) -> [PlanetaryAspect] {
        var aspects: [PlanetaryAspect] = []

        for pos1 in positions1 {
            for pos2 in positions2 {
                guard pos1.planet != pos2.planet else { continue }

                if let aspect = findAspect(between: pos1, and: pos2) {
                    aspects.append(aspect)
                }
            }
        }

        return aspects
    }

    func findAspect(between pos1: PlanetaryPosition, and pos2: PlanetaryPosition) -> PlanetaryAspect? {
        var angle = abs(pos1.longitude - pos2.longitude)
        if angle > 180 { angle = 360 - angle }

        for aspectType in Aspect.allCases {
            let orb = abs(angle - aspectType.angle)
            if orb <= aspectType.orb {
                let isApplying = pos1.speedLongitude > pos2.speedLongitude
                return PlanetaryAspect(
                    planet1: pos1.planet,
                    planet2: pos2.planet,
                    aspect: aspectType,
                    orb: orb,
                    isApplying: isApplying
                )
            }
        }

        return nil
    }

    func getActiveRetrogrades(for date: Date) -> [Planet] {
        let positions = calculatePlanetaryPositions(for: date)
        return positions.filter { $0.isRetrograde && $0.planet.canBeRetrograde }.map { $0.planet }
    }

    func calculateBirthChart(for user: User) -> BirthChart {
        let positions = calculatePlanetaryPositions(for: user.fullBirthDateTime)

        let sunSign = positions.first(where: { $0.planet == .sun })?.sign ?? .aries
        let moonSign = positions.first(where: { $0.planet == .moon })?.sign ?? .aries

        var risingSign: ZodiacSign? = nil
        if user.hasBirthTime {
            risingSign = calculateAscendant(
                julianDay: user.julianDay,
                latitude: user.birthLatitude,
                longitude: user.birthLongitude
            )
        }

        return BirthChart(
            sunSign: sunSign,
            moonSign: moonSign,
            risingSign: risingSign,
            planetaryPositions: positions,
            calculatedAt: Date()
        )
    }

    private func calculateAscendant(julianDay: Double, latitude: Double, longitude: Double) -> ZodiacSign {
        let lst = calculateLocalSiderealTime(julianDay: julianDay, longitude: longitude)
        let obliquity = 23.4393
        let latRad = latitude * .pi / 180.0
        let oblRad = obliquity * .pi / 180.0
        let lstRad = lst * .pi / 180.0

        let y = cos(lstRad)
        let x = -sin(lstRad) * cos(oblRad) - tan(latRad) * sin(oblRad)
        var ascendant = atan2(y, x) * 180.0 / .pi

        if ascendant < 0 { ascendant += 360.0 }

        return ZodiacSign.from(degree: ascendant)
    }

    private func calculateLocalSiderealTime(julianDay: Double, longitude: Double) -> Double {
        let j2000 = 2451545.0
        let d = julianDay - j2000
        let t = d / 36525.0

        var gmst = 280.46061837 + 360.98564736629 * d + 0.000387933 * t * t
        gmst = gmst.truncatingRemainder(dividingBy: 360.0)
        if gmst < 0 { gmst += 360.0 }

        var lst = gmst + longitude
        lst = lst.truncatingRemainder(dividingBy: 360.0)
        if lst < 0 { lst += 360.0 }

        return lst
    }

    private func swissEphemerisPlanetId(for planet: Planet) -> Int32 {
        switch planet {
        case .sun: return 0
        case .moon: return 1
        case .mercury: return 2
        case .venus: return 3
        case .mars: return 4
        case .jupiter: return 5
        case .saturn: return 6
        case .uranus: return 7
        case .neptune: return 8
        case .pluto: return 9
        }
    }

    func julianDayFromDate(_ date: Date) -> Double {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)

        let year = Double(components.year ?? 2000)
        let month = Double(components.month ?? 1)
        let day = Double(components.day ?? 1)
        let hour = Double(components.hour ?? 12)
        let minute = Double(components.minute ?? 0)
        let second = Double(components.second ?? 0)

        let decimalDay = day + (hour + minute / 60.0 + second / 3600.0) / 24.0

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

extension Date {
    init(julianDay: Double) {
        let z = Int(julianDay + 0.5)
        let f = julianDay + 0.5 - Double(z)

        var a = z
        if z >= 2299161 {
            let alpha = Int((Double(z) - 1867216.25) / 36524.25)
            a = z + 1 + alpha - alpha / 4
        }

        let b = a + 1524
        let c = Int((Double(b) - 122.1) / 365.25)
        let d = Int(365.25 * Double(c))
        let e = Int(Double(b - d) / 30.6001)

        let day = b - d - Int(30.6001 * Double(e)) + Int(f)
        let month = e < 14 ? e - 1 : e - 13
        let year = month > 2 ? c - 4716 : c - 4715

        let fractionalDay = f
        let hours = fractionalDay * 24.0
        let hour = Int(hours)
        let minutes = (hours - Double(hour)) * 60.0
        let minute = Int(minutes)
        let second = Int((minutes - Double(minute)) * 60.0)

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        components.timeZone = TimeZone(identifier: "UTC")

        self = Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }
}
