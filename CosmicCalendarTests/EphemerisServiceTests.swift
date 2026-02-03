import XCTest
@testable import CosmicCalendar

final class EphemerisServiceTests: XCTestCase {

    private var ephemeris: EphemerisService!

    override func setUp() {
        super.setUp()
        ephemeris = EphemerisService.shared
    }

    // MARK: - Julian Day Conversion Tests

    func testJ2000EpochJulianDay() {
        let j2000Date = createDate(year: 2000, month: 1, day: 1, hour: 12)
        let julianDay = ephemeris.julianDayFromDate(j2000Date)

        XCTAssertEqual(julianDay, 2451545.0, accuracy: 0.01,
            "J2000.0 epoch (2000-01-01 12:00 UTC) should be Julian Day 2451545.0")
    }

    func testJulianDayFromKnownDate() {
        let date = createDate(year: 2024, month: 3, day: 20, hour: 12)
        let julianDay = ephemeris.julianDayFromDate(date)

        XCTAssertGreaterThan(julianDay, 2451545.0,
            "Date after J2000 should have larger Julian Day")
        XCTAssertEqual(julianDay, 2460389.0, accuracy: 0.5,
            "2024-03-20 12:00 UTC should be approximately JD 2460389")
    }

    func testJulianDayRoundTripConversion() {
        let originalDate = createDate(year: 2026, month: 6, day: 15, hour: 12)
        let julianDay = ephemeris.julianDayFromDate(originalDate)
        let convertedDate = Date(julianDay: julianDay)

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: convertedDate)

        XCTAssertEqual(components.year, 2026, "Year should be preserved in round trip")
        XCTAssertEqual(components.month, 6, "Month should be preserved in round trip")
        XCTAssertEqual(components.day, 15, "Day should be preserved in round trip")
        XCTAssertEqual(components.hour, 12, "Hour should be preserved in round trip")
    }

    func testJulianDayRoundTripMultipleDates() {
        let testDates = [
            createDate(year: 1999, month: 12, day: 31, hour: 23),
            createDate(year: 2000, month: 1, day: 1, hour: 0),
            createDate(year: 2024, month: 2, day: 29, hour: 12),
            createDate(year: 2026, month: 7, day: 4, hour: 18),
            createDate(year: 2030, month: 12, day: 31, hour: 6)
        ]

        for originalDate in testDates {
            let julianDay = ephemeris.julianDayFromDate(originalDate)
            let convertedDate = Date(julianDay: julianDay)

            let calendar = Calendar(identifier: .gregorian)
            let originalComponents = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: originalDate)
            let convertedComponents = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: convertedDate)

            XCTAssertEqual(originalComponents.year, convertedComponents.year,
                "Year should match after round trip for \(originalDate)")
            XCTAssertEqual(originalComponents.month, convertedComponents.month,
                "Month should match after round trip for \(originalDate)")
            XCTAssertEqual(originalComponents.day, convertedComponents.day,
                "Day should match after round trip for \(originalDate)")
        }
    }

    func testJulianDayFromDateExtension() {
        let julianDay = 2451545.0
        let date = Date(julianDay: julianDay)

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)

        XCTAssertEqual(components.year, 2000, "J2000 should convert to year 2000")
        XCTAssertEqual(components.month, 1, "J2000 should convert to January")
        XCTAssertEqual(components.day, 1, "J2000 should convert to day 1")
    }

    func testJulianDayIncreasesMonotonically() {
        var previousJD = 0.0

        for dayOffset in 0..<365 {
            let date = Calendar.current.date(byAdding: .day, value: dayOffset,
                to: createDate(year: 2026, month: 1, day: 1, hour: 12))!
            let julianDay = ephemeris.julianDayFromDate(date)

            XCTAssertGreaterThan(julianDay, previousJD,
                "Julian Day should increase with each subsequent day")
            previousJD = julianDay
        }
    }

    // MARK: - Planetary Position Tests

    func testCalculatePlanetaryPositionsReturnsAllPlanets() {
        let date = Date()
        let positions = ephemeris.calculatePlanetaryPositions(for: date)

        XCTAssertEqual(positions.count, Planet.allCases.count,
            "Should return positions for all \(Planet.allCases.count) planets")

        for planet in Planet.allCases {
            let hasPosition = positions.contains { $0.planet == planet }
            XCTAssertTrue(hasPosition, "Should have position for \(planet.rawValue)")
        }
    }

    func testPlanetaryLongitudesAreWithinValidRange() {
        let testDates = generateTestDates(count: 20)

        for date in testDates {
            let positions = ephemeris.calculatePlanetaryPositions(for: date)

            for position in positions {
                XCTAssertGreaterThanOrEqual(position.longitude, 0.0,
                    "\(position.planet.rawValue) longitude should be >= 0 for \(date)")
                XCTAssertLessThan(position.longitude, 360.0,
                    "\(position.planet.rawValue) longitude should be < 360 for \(date)")
            }
        }
    }

    func testSunPositionCalculation() {
        let julianDay = 2451545.0
        let position = ephemeris.calculatePlanetPosition(planet: .sun, julianDay: julianDay)

        XCTAssertEqual(position.planet, .sun)
        XCTAssertGreaterThanOrEqual(position.longitude, 0.0)
        XCTAssertLessThan(position.longitude, 360.0)
        XCTAssertFalse(position.isRetrograde, "Sun should never be retrograde")
    }

    func testMoonPositionCalculation() {
        let julianDay = 2451545.0
        let position = ephemeris.calculatePlanetPosition(planet: .moon, julianDay: julianDay)

        XCTAssertEqual(position.planet, .moon)
        XCTAssertGreaterThanOrEqual(position.longitude, 0.0)
        XCTAssertLessThan(position.longitude, 360.0)
        XCTAssertFalse(position.isRetrograde, "Moon should never be retrograde")
    }

    func testMercuryPositionCalculation() {
        let julianDay = 2460400.0
        let position = ephemeris.calculatePlanetPosition(planet: .mercury, julianDay: julianDay)

        XCTAssertEqual(position.planet, .mercury)
        XCTAssertGreaterThanOrEqual(position.longitude, 0.0)
        XCTAssertLessThan(position.longitude, 360.0)
    }

    func testAllPlanetPositionsHaveValidSpeed() {
        let date = Date()
        let positions = ephemeris.calculatePlanetaryPositions(for: date)

        for position in positions {
            XCTAssertFalse(position.speedLongitude.isNaN,
                "\(position.planet.rawValue) speed should not be NaN")
            XCTAssertFalse(position.speedLongitude.isInfinite,
                "\(position.planet.rawValue) speed should not be infinite")
        }
    }

    func testPlanetPositionZodiacSignAssignment() {
        let positions = ephemeris.calculatePlanetaryPositions(for: Date())

        for position in positions {
            let sign = position.sign
            XCTAssertTrue(ZodiacSign.allCases.contains(sign),
                "\(position.planet.rawValue) should have a valid zodiac sign")

            let expectedSign = ZodiacSign.from(degree: position.longitude)
            XCTAssertEqual(position.sign, expectedSign,
                "\(position.planet.rawValue) sign should match degree-based calculation")
        }
    }

    // MARK: - Moon Phase Tests

    func testMoonPhaseCalculation() {
        let date = Date()
        let phase = ephemeris.calculateMoonPhase(for: date)

        XCTAssertTrue(MoonPhase.allCases.contains(phase),
            "Moon phase should be a valid MoonPhase case")
    }

    func testMoonPhaseNewMoonCondition() {
        let phase = MoonPhase.from(illumination: 0.0, isWaxing: true)
        XCTAssertEqual(phase, .newMoon, "0% illumination should be new moon")

        let phase2 = MoonPhase.from(illumination: 0.02, isWaxing: true)
        XCTAssertEqual(phase2, .newMoon, "Very low illumination should be new moon")
    }

    func testMoonPhaseFullMoonCondition() {
        let phase = MoonPhase.from(illumination: 1.0, isWaxing: true)
        XCTAssertEqual(phase, .fullMoon, "100% illumination should be full moon")

        let phase2 = MoonPhase.from(illumination: 0.98, isWaxing: true)
        XCTAssertEqual(phase2, .fullMoon, "Near-full illumination waxing should be full moon")

        let phase3 = MoonPhase.from(illumination: 0.98, isWaxing: false)
        XCTAssertEqual(phase3, .fullMoon, "Near-full illumination waning should be full moon")
    }

    func testMoonPhaseWaxingCrescent() {
        let phase = MoonPhase.from(illumination: 0.15, isWaxing: true)
        XCTAssertEqual(phase, .waxingCrescent, "Low illumination waxing should be waxing crescent")
    }

    func testMoonPhaseFirstQuarter() {
        let phase = MoonPhase.from(illumination: 0.40, isWaxing: true)
        XCTAssertEqual(phase, .firstQuarter, "~50% illumination waxing should be first quarter")
    }

    func testMoonPhaseWaxingGibbous() {
        let phase = MoonPhase.from(illumination: 0.65, isWaxing: true)
        XCTAssertEqual(phase, .waxingGibbous, "High illumination waxing should be waxing gibbous")
    }

    func testMoonPhaseWaningGibbous() {
        let phase = MoonPhase.from(illumination: 0.85, isWaxing: false)
        XCTAssertEqual(phase, .waningGibbous, "High illumination waning should be waning gibbous")
    }

    func testMoonPhaseLastQuarter() {
        let phase = MoonPhase.from(illumination: 0.55, isWaxing: false)
        XCTAssertEqual(phase, .lastQuarter, "~50% illumination waning should be last quarter")
    }

    func testMoonPhaseWaningCrescent() {
        let phase = MoonPhase.from(illumination: 0.15, isWaxing: false)
        XCTAssertEqual(phase, .waningCrescent, "Low illumination waning should be waning crescent")
    }

    func testAllMoonPhasesHaveScoreModifier() {
        for phase in MoonPhase.allCases {
            XCTAssertFalse(phase.scoreModifier.isNaN,
                "\(phase.rawValue) should have valid score modifier")
            XCTAssertGreaterThanOrEqual(phase.scoreModifier, -1.0,
                "\(phase.rawValue) modifier should be >= -1.0")
            XCTAssertLessThanOrEqual(phase.scoreModifier, 1.5,
                "\(phase.rawValue) modifier should be <= 1.5")
        }
    }

    // MARK: - Retrograde Motion Tests

    func testSunCannotBeRetrograde() {
        XCTAssertFalse(Planet.sun.canBeRetrograde, "Sun cannot be retrograde")

        let testDates = generateTestDates(count: 50)
        for date in testDates {
            let positions = ephemeris.calculatePlanetaryPositions(for: date)
            let sunPosition = positions.first { $0.planet == .sun }

            XCTAssertNotNil(sunPosition)
            XCTAssertFalse(sunPosition!.isRetrograde,
                "Sun should never be retrograde for any date")
        }
    }

    func testMoonCannotBeRetrograde() {
        XCTAssertFalse(Planet.moon.canBeRetrograde, "Moon cannot be retrograde")

        let testDates = generateTestDates(count: 50)
        for date in testDates {
            let positions = ephemeris.calculatePlanetaryPositions(for: date)
            let moonPosition = positions.first { $0.planet == .moon }

            XCTAssertNotNil(moonPosition)
            XCTAssertFalse(moonPosition!.isRetrograde,
                "Moon should never be retrograde for any date")
        }
    }

    func testMercuryCanBeRetrograde() {
        XCTAssertTrue(Planet.mercury.canBeRetrograde, "Mercury can be retrograde")
    }

    func testVenusCanBeRetrograde() {
        XCTAssertTrue(Planet.venus.canBeRetrograde, "Venus can be retrograde")
    }

    func testMarsCanBeRetrograde() {
        XCTAssertTrue(Planet.mars.canBeRetrograde, "Mars can be retrograde")
    }

    func testOuterPlanetsCanBeRetrograde() {
        XCTAssertTrue(Planet.jupiter.canBeRetrograde, "Jupiter can be retrograde")
        XCTAssertTrue(Planet.saturn.canBeRetrograde, "Saturn can be retrograde")
        XCTAssertTrue(Planet.uranus.canBeRetrograde, "Uranus can be retrograde")
        XCTAssertTrue(Planet.neptune.canBeRetrograde, "Neptune can be retrograde")
        XCTAssertTrue(Planet.pluto.canBeRetrograde, "Pluto can be retrograde")
    }

    func testMercuryRetrogradeDetection() {
        let retrogradeDate = createDateFromJulianDay(2460340.0)
        let retrogrades = ephemeris.getActiveRetrogrades(for: retrogradeDate)

        XCTAssertTrue(retrogrades.contains(.mercury),
            "Mercury should be retrograde around JD 2460340")
    }

    func testNoRetrogradesOnClearDate() {
        let clearDate = createDateFromJulianDay(2460400.0)
        let retrogrades = ephemeris.getActiveRetrogrades(for: clearDate)

        XCTAssertFalse(retrogrades.contains(.sun), "Sun should never be in retrograde list")
        XCTAssertFalse(retrogrades.contains(.moon), "Moon should never be in retrograde list")
    }

    func testGetActiveRetrogrades() {
        let date = Date()
        let retrogrades = ephemeris.getActiveRetrogrades(for: date)

        for planet in retrogrades {
            XCTAssertTrue(planet.canBeRetrograde,
                "\(planet.rawValue) in retrograde list should be able to be retrograde")
        }
    }

    func testRetrogradePositionHasNegativeSpeed() {
        let retrogradeDate = createDateFromJulianDay(2460340.0)
        let positions = ephemeris.calculatePlanetaryPositions(for: retrogradeDate)

        for position in positions {
            if position.isRetrograde {
                XCTAssertLessThan(position.speedLongitude, 0,
                    "\(position.planet.rawValue) retrograde should have negative speed")
            }
        }
    }

    // MARK: - Aspect Detection Tests

    func testFindAspectConjunction() {
        let pos1 = PlanetaryPosition(
            planet: .sun,
            longitude: 100.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 1.0,
            isRetrograde: false
        )
        let pos2 = PlanetaryPosition(
            planet: .moon,
            longitude: 105.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 13.0,
            isRetrograde: false
        )

        let aspect = ephemeris.findAspect(between: pos1, and: pos2)

        XCTAssertNotNil(aspect, "Should find conjunction aspect within orb")
        XCTAssertEqual(aspect?.aspect, .conjunction, "Should be a conjunction")
        XCTAssertEqual(aspect?.planet1, .sun)
        XCTAssertEqual(aspect?.planet2, .moon)
    }

    func testFindAspectSextile() {
        let pos1 = PlanetaryPosition(
            planet: .venus,
            longitude: 60.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 1.0,
            isRetrograde: false
        )
        let pos2 = PlanetaryPosition(
            planet: .mars,
            longitude: 120.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 0.5,
            isRetrograde: false
        )

        let aspect = ephemeris.findAspect(between: pos1, and: pos2)

        XCTAssertNotNil(aspect, "Should find sextile aspect at 60 degrees")
        XCTAssertEqual(aspect?.aspect, .sextile, "Should be a sextile")
    }

    func testFindAspectSquare() {
        let pos1 = PlanetaryPosition(
            planet: .mercury,
            longitude: 0.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 1.0,
            isRetrograde: false
        )
        let pos2 = PlanetaryPosition(
            planet: .saturn,
            longitude: 90.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 0.03,
            isRetrograde: false
        )

        let aspect = ephemeris.findAspect(between: pos1, and: pos2)

        XCTAssertNotNil(aspect, "Should find square aspect at 90 degrees")
        XCTAssertEqual(aspect?.aspect, .square, "Should be a square")
    }

    func testFindAspectTrine() {
        let pos1 = PlanetaryPosition(
            planet: .jupiter,
            longitude: 30.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 0.08,
            isRetrograde: false
        )
        let pos2 = PlanetaryPosition(
            planet: .neptune,
            longitude: 150.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 0.006,
            isRetrograde: false
        )

        let aspect = ephemeris.findAspect(between: pos1, and: pos2)

        XCTAssertNotNil(aspect, "Should find trine aspect at 120 degrees")
        XCTAssertEqual(aspect?.aspect, .trine, "Should be a trine")
    }

    func testFindAspectOpposition() {
        let pos1 = PlanetaryPosition(
            planet: .sun,
            longitude: 0.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 1.0,
            isRetrograde: false
        )
        let pos2 = PlanetaryPosition(
            planet: .moon,
            longitude: 180.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 13.0,
            isRetrograde: false
        )

        let aspect = ephemeris.findAspect(between: pos1, and: pos2)

        XCTAssertNotNil(aspect, "Should find opposition aspect at 180 degrees")
        XCTAssertEqual(aspect?.aspect, .opposition, "Should be an opposition")
    }

    func testNoAspectOutsideOrb() {
        let pos1 = PlanetaryPosition(
            planet: .sun,
            longitude: 0.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 1.0,
            isRetrograde: false
        )
        let pos2 = PlanetaryPosition(
            planet: .moon,
            longitude: 45.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 13.0,
            isRetrograde: false
        )

        let aspect = ephemeris.findAspect(between: pos1, and: pos2)

        XCTAssertNil(aspect, "Should not find aspect at 45 degrees (not a major aspect)")
    }

    func testAspectOrbTolerance() {
        let pos1 = PlanetaryPosition(
            planet: .sun,
            longitude: 0.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 1.0,
            isRetrograde: false
        )
        let pos2 = PlanetaryPosition(
            planet: .moon,
            longitude: 127.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 13.0,
            isRetrograde: false
        )

        let aspect = ephemeris.findAspect(between: pos1, and: pos2)

        XCTAssertNotNil(aspect, "Should find trine within 8 degree orb (127 vs 120)")
        XCTAssertEqual(aspect?.aspect, .trine)
        XCTAssertEqual(aspect?.orb ?? 0, 7.0, accuracy: 0.1, "Orb should be approximately 7 degrees")
    }

    func testCalculateAspectsBetweenPositions() {
        let positions1 = ephemeris.calculatePlanetaryPositions(for: Date())
        let positions2 = positions1

        let aspects = ephemeris.calculateAspects(between: positions1, and: positions2)

        for aspect in aspects {
            XCTAssertNotEqual(aspect.planet1, aspect.planet2,
                "Aspects should not be between the same planet")
            XCTAssertTrue(Aspect.allCases.contains(aspect.aspect),
                "Aspect type should be valid")
            XCTAssertLessThanOrEqual(aspect.orb, aspect.aspect.orb,
                "Aspect orb should be within allowed tolerance")
        }
    }

    func testAspectIsApplyingCalculation() {
        let fasterPos = PlanetaryPosition(
            planet: .moon,
            longitude: 100.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 13.0,
            isRetrograde: false
        )
        let slowerPos = PlanetaryPosition(
            planet: .sun,
            longitude: 103.0,
            latitude: 0.0,
            distance: 1.0,
            speedLongitude: 1.0,
            isRetrograde: false
        )

        let aspect = ephemeris.findAspect(between: fasterPos, and: slowerPos)

        XCTAssertNotNil(aspect)
        XCTAssertTrue(aspect!.isApplying,
            "Moon (faster) approaching Sun should be applying")
    }

    // MARK: - Birth Chart Tests

    func testCalculateBirthChartReturnsValidChart() {
        let user = createTestUser()
        let chart = ephemeris.calculateBirthChart(for: user)

        XCTAssertTrue(ZodiacSign.allCases.contains(chart.sunSign),
            "Sun sign should be valid")
        XCTAssertTrue(ZodiacSign.allCases.contains(chart.moonSign),
            "Moon sign should be valid")
        XCTAssertEqual(chart.planetaryPositions.count, Planet.allCases.count,
            "Birth chart should have positions for all planets")
    }

    func testBirthChartPlanetaryPositions() {
        let user = createTestUser()
        let chart = ephemeris.calculateBirthChart(for: user)

        for planet in Planet.allCases {
            let hasPosition = chart.planetaryPositions.contains { $0.planet == planet }
            XCTAssertTrue(hasPosition,
                "Birth chart should have position for \(planet.rawValue)")
        }
    }

    func testBirthChartSunSignMatchesPosition() {
        let user = createTestUser()
        let chart = ephemeris.calculateBirthChart(for: user)

        let sunPosition = chart.planetaryPositions.first { $0.planet == .sun }
        XCTAssertNotNil(sunPosition, "Should have sun position")
        XCTAssertEqual(chart.sunSign, sunPosition!.sign,
            "Sun sign should match position's sign")
    }

    func testBirthChartMoonSignMatchesPosition() {
        let user = createTestUser()
        let chart = ephemeris.calculateBirthChart(for: user)

        let moonPosition = chart.planetaryPositions.first { $0.planet == .moon }
        XCTAssertNotNil(moonPosition, "Should have moon position")
        XCTAssertEqual(chart.moonSign, moonPosition!.sign,
            "Moon sign should match position's sign")
    }

    func testBirthChartWithBirthTimeHasRisingSign() {
        let user = createTestUserWithBirthTime()
        let chart = ephemeris.calculateBirthChart(for: user)

        XCTAssertNotNil(chart.risingSign,
            "Birth chart with birth time should have rising sign")
        XCTAssertTrue(ZodiacSign.allCases.contains(chart.risingSign!),
            "Rising sign should be valid")
    }

    func testBirthChartHasCalculatedAtDate() {
        let user = createTestUser()
        let chart = ephemeris.calculateBirthChart(for: user)

        XCTAssertNotNil(chart.calculatedAt)
        XCTAssertLessThanOrEqual(chart.calculatedAt, Date(),
            "calculatedAt should be at or before current time")
    }

    // MARK: - Zodiac Sign Assignment Tests

    func testZodiacSignFromDegreeAries() {
        XCTAssertEqual(ZodiacSign.from(degree: 0), .aries, "0 degrees should be Aries")
        XCTAssertEqual(ZodiacSign.from(degree: 15), .aries, "15 degrees should be Aries")
        XCTAssertEqual(ZodiacSign.from(degree: 29.99), .aries, "29.99 degrees should be Aries")
    }

    func testZodiacSignFromDegreeTaurus() {
        XCTAssertEqual(ZodiacSign.from(degree: 30), .taurus, "30 degrees should be Taurus")
        XCTAssertEqual(ZodiacSign.from(degree: 45), .taurus, "45 degrees should be Taurus")
    }

    func testZodiacSignFromDegreeGemini() {
        XCTAssertEqual(ZodiacSign.from(degree: 60), .gemini, "60 degrees should be Gemini")
        XCTAssertEqual(ZodiacSign.from(degree: 75), .gemini, "75 degrees should be Gemini")
    }

    func testZodiacSignFromDegreeCancer() {
        XCTAssertEqual(ZodiacSign.from(degree: 90), .cancer, "90 degrees should be Cancer")
    }

    func testZodiacSignFromDegreeLeo() {
        XCTAssertEqual(ZodiacSign.from(degree: 120), .leo, "120 degrees should be Leo")
    }

    func testZodiacSignFromDegreeVirgo() {
        XCTAssertEqual(ZodiacSign.from(degree: 150), .virgo, "150 degrees should be Virgo")
    }

    func testZodiacSignFromDegreeLibra() {
        XCTAssertEqual(ZodiacSign.from(degree: 180), .libra, "180 degrees should be Libra")
    }

    func testZodiacSignFromDegreeScorpio() {
        XCTAssertEqual(ZodiacSign.from(degree: 210), .scorpio, "210 degrees should be Scorpio")
    }

    func testZodiacSignFromDegreeSagittarius() {
        XCTAssertEqual(ZodiacSign.from(degree: 240), .sagittarius, "240 degrees should be Sagittarius")
    }

    func testZodiacSignFromDegreeCapricorn() {
        XCTAssertEqual(ZodiacSign.from(degree: 270), .capricorn, "270 degrees should be Capricorn")
    }

    func testZodiacSignFromDegreeAquarius() {
        XCTAssertEqual(ZodiacSign.from(degree: 300), .aquarius, "300 degrees should be Aquarius")
    }

    func testZodiacSignFromDegreePisces() {
        XCTAssertEqual(ZodiacSign.from(degree: 330), .pisces, "330 degrees should be Pisces")
        XCTAssertEqual(ZodiacSign.from(degree: 359.99), .pisces, "359.99 degrees should be Pisces")
    }

    func testZodiacSignNormalizesDegreesOver360() {
        XCTAssertEqual(ZodiacSign.from(degree: 360), .aries, "360 degrees should normalize to Aries")
        XCTAssertEqual(ZodiacSign.from(degree: 390), .aries, "390 degrees should normalize to Aries")
        XCTAssertEqual(ZodiacSign.from(degree: 720), .aries, "720 degrees should normalize to Aries")
    }

    // MARK: - Boundary & Edge Case Tests

    func testLeapYearFebruary29() {
        let leapDate = createDate(year: 2024, month: 2, day: 29, hour: 12)
        let positions = ephemeris.calculatePlanetaryPositions(for: leapDate)

        XCTAssertEqual(positions.count, Planet.allCases.count,
            "Should calculate positions for leap year date")

        for position in positions {
            XCTAssertGreaterThanOrEqual(position.longitude, 0.0)
            XCTAssertLessThan(position.longitude, 360.0)
        }
    }

    func testYearBoundaryDecember31ToJanuary1() {
        let dec31 = createDate(year: 2025, month: 12, day: 31, hour: 23)
        let jan1 = createDate(year: 2026, month: 1, day: 1, hour: 0)

        let positions1 = ephemeris.calculatePlanetaryPositions(for: dec31)
        let positions2 = ephemeris.calculatePlanetaryPositions(for: jan1)

        XCTAssertEqual(positions1.count, positions2.count,
            "Should have same planet count across year boundary")

        for (pos1, pos2) in zip(positions1, positions2) {
            XCTAssertEqual(pos1.planet, pos2.planet,
                "Planet order should be consistent")
        }
    }

    func testJ2000EpochCalculation() {
        let j2000 = createDate(year: 2000, month: 1, day: 1, hour: 12)
        let positions = ephemeris.calculatePlanetaryPositions(for: j2000)

        XCTAssertEqual(positions.count, Planet.allCases.count,
            "Should calculate positions for J2000 epoch")

        let sunPosition = positions.first { $0.planet == .sun }
        XCTAssertNotNil(sunPosition)
        XCTAssertEqual(sunPosition!.longitude, 280.46, accuracy: 1.0,
            "Sun longitude at J2000 should be approximately 280.46 degrees")
    }

    func testUTCTimezoneConsistency() {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 15
        components.hour = 12
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(identifier: "UTC")

        let utcDate = Calendar(identifier: .gregorian).date(from: components)!

        let julianDay = ephemeris.julianDayFromDate(utcDate)
        let convertedDate = Date(julianDay: julianDay)

        let calendar = Calendar(identifier: .gregorian)
        let originalComponents = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: utcDate)
        let convertedComponents = calendar.dateComponents(in: TimeZone(identifier: "UTC")!, from: convertedDate)

        XCTAssertEqual(originalComponents.year, convertedComponents.year)
        XCTAssertEqual(originalComponents.month, convertedComponents.month)
        XCTAssertEqual(originalComponents.day, convertedComponents.day)
        XCTAssertEqual(originalComponents.hour, convertedComponents.hour)
    }

    func testDistantPastDate() {
        let pastDate = createDate(year: 1900, month: 1, day: 1, hour: 12)
        let positions = ephemeris.calculatePlanetaryPositions(for: pastDate)

        XCTAssertEqual(positions.count, Planet.allCases.count,
            "Should calculate positions for distant past date")

        for position in positions {
            XCTAssertGreaterThanOrEqual(position.longitude, 0.0)
            XCTAssertLessThan(position.longitude, 360.0)
        }
    }

    func testDistantFutureDate() {
        let futureDate = createDate(year: 2100, month: 12, day: 31, hour: 12)
        let positions = ephemeris.calculatePlanetaryPositions(for: futureDate)

        XCTAssertEqual(positions.count, Planet.allCases.count,
            "Should calculate positions for distant future date")

        for position in positions {
            XCTAssertGreaterThanOrEqual(position.longitude, 0.0)
            XCTAssertLessThan(position.longitude, 360.0)
        }
    }

    // MARK: - Deterministic Calculation Tests

    func testSameDateProducesSamePlanetaryPositions() {
        let date = createDate(year: 2026, month: 7, day: 4, hour: 12)

        let result1 = ephemeris.calculatePlanetaryPositions(for: date)
        let result2 = ephemeris.calculatePlanetaryPositions(for: date)

        XCTAssertEqual(result1.count, result2.count)

        for (pos1, pos2) in zip(result1, result2) {
            XCTAssertEqual(pos1.planet, pos2.planet)
            XCTAssertEqual(pos1.longitude, pos2.longitude, accuracy: 0.0001,
                "\(pos1.planet.rawValue) longitude should be deterministic")
            XCTAssertEqual(pos1.isRetrograde, pos2.isRetrograde,
                "\(pos1.planet.rawValue) retrograde status should be deterministic")
        }
    }

    func testSameDateProducesSameMoonPhase() {
        let date = createDate(year: 2026, month: 3, day: 15, hour: 12)

        let phase1 = ephemeris.calculateMoonPhase(for: date)
        let phase2 = ephemeris.calculateMoonPhase(for: date)

        XCTAssertEqual(phase1, phase2,
            "Same date should produce same moon phase")
    }

    func testSameJulianDayProducesSamePosition() {
        let julianDay = 2460500.0

        let position1 = ephemeris.calculatePlanetPosition(planet: .venus, julianDay: julianDay)
        let position2 = ephemeris.calculatePlanetPosition(planet: .venus, julianDay: julianDay)

        XCTAssertEqual(position1.longitude, position2.longitude, accuracy: 0.0001,
            "Same Julian Day should produce same longitude")
        XCTAssertEqual(position1.isRetrograde, position2.isRetrograde,
            "Same Julian Day should produce same retrograde status")
    }

    func testDifferentDatesProduceDifferentPositions() {
        let date1 = createDate(year: 2026, month: 1, day: 1, hour: 12)
        let date2 = createDate(year: 2026, month: 6, day: 15, hour: 12)

        let positions1 = ephemeris.calculatePlanetaryPositions(for: date1)
        let positions2 = ephemeris.calculatePlanetaryPositions(for: date2)

        var hasDifference = false
        for (pos1, pos2) in zip(positions1, positions2) {
            if pos1.longitude != pos2.longitude {
                hasDifference = true
                break
            }
        }

        XCTAssertTrue(hasDifference,
            "Different dates should produce different planetary positions")
    }

    func testConsecutiveDaysShowPlanetaryMotion() {
        let day1 = createDate(year: 2026, month: 5, day: 1, hour: 12)
        let day2 = createDate(year: 2026, month: 5, day: 2, hour: 12)

        let positions1 = ephemeris.calculatePlanetaryPositions(for: day1)
        let positions2 = ephemeris.calculatePlanetaryPositions(for: day2)

        let moon1 = positions1.first { $0.planet == .moon }!
        let moon2 = positions2.first { $0.planet == .moon }!

        XCTAssertNotEqual(moon1.longitude, moon2.longitude,
            "Moon should move noticeably in one day (~13 degrees)")

        let sun1 = positions1.first { $0.planet == .sun }!
        let sun2 = positions2.first { $0.planet == .sun }!

        XCTAssertNotEqual(sun1.longitude, sun2.longitude,
            "Sun should move noticeably in one day (~1 degree)")
    }

    // MARK: - Helper Methods

    private func generateTestDates(count: Int) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let startDate = createDate(year: 2026, month: 1, day: 1, hour: 12)

        for i in 0..<count {
            if let date = calendar.date(byAdding: .day, value: i * 10, to: startDate) {
                dates.append(date)
            }
        }

        return dates
    }

    private func createDate(year: Int, month: Int, day: Int, hour: Int = 12) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(identifier: "UTC")

        return Calendar(identifier: .gregorian).date(from: components) ?? Date()
    }

    private func createDateFromJulianDay(_ julianDay: Double) -> Date {
        return Date(julianDay: julianDay)
    }

    private func createTestUser() -> User {
        return User(
            name: "Test User",
            birthDate: createDate(year: 1990, month: 6, day: 15, hour: 12),
            birthTime: nil,
            birthLocationName: "New York, NY",
            birthLatitude: 40.7128,
            birthLongitude: -74.0060,
            birthTimezone: "America/New_York"
        )
    }

    private func createTestUserWithBirthTime() -> User {
        let birthDate = createDate(year: 1990, month: 6, day: 15, hour: 12)
        var timeComponents = DateComponents()
        timeComponents.hour = 14
        timeComponents.minute = 30
        let birthTime = Calendar.current.date(from: timeComponents) ?? Date()

        return User(
            name: "Test User",
            birthDate: birthDate,
            birthTime: birthTime,
            birthLocationName: "New York, NY",
            birthLatitude: 40.7128,
            birthLongitude: -74.0060,
            birthTimezone: "America/New_York"
        )
    }
}
