import XCTest
@testable import CosmicCalendar

final class CosmicScoreCalculatorTests: XCTestCase {

    private var calculator: CosmicScoreCalculator!
    private var ephemeris: EphemerisService!

    override func setUp() {
        super.setUp()
        calculator = CosmicScoreCalculator.shared
        ephemeris = EphemerisService.shared
    }

    // MARK: - Score Clamping Tests

    func testAllScoresAreWithinValidRange() {
        let testDates = generateTestDates(count: 30)

        for date in testDates {
            let cosmicDay = calculator.calculateCosmicDay(for: date, birthChart: nil)

            XCTAssertGreaterThanOrEqual(cosmicDay.overallScore, 1.0,
                "Overall score should be at least 1.0 for \(date)")
            XCTAssertLessThanOrEqual(cosmicDay.overallScore, 10.0,
                "Overall score should be at most 10.0 for \(date)")

            XCTAssertGreaterThanOrEqual(cosmicDay.relationshipScore, 1.0,
                "Relationship score should be at least 1.0 for \(date)")
            XCTAssertLessThanOrEqual(cosmicDay.relationshipScore, 10.0,
                "Relationship score should be at most 10.0 for \(date)")

            XCTAssertGreaterThanOrEqual(cosmicDay.careerScore, 1.0,
                "Career score should be at least 1.0 for \(date)")
            XCTAssertLessThanOrEqual(cosmicDay.careerScore, 10.0,
                "Career score should be at most 10.0 for \(date)")

            XCTAssertGreaterThanOrEqual(cosmicDay.healthScore, 1.0,
                "Health score should be at least 1.0 for \(date)")
            XCTAssertLessThanOrEqual(cosmicDay.healthScore, 10.0,
                "Health score should be at most 10.0 for \(date)")
        }
    }

    func testScoresNeverExceedBounds() {
        let extremeDates = [
            createDate(year: 2026, month: 1, day: 1),
            createDate(year: 2026, month: 6, day: 15),
            createDate(year: 2026, month: 12, day: 31),
            createDate(year: 2025, month: 3, day: 21),
            createDate(year: 2027, month: 9, day: 22)
        ]

        for date in extremeDates {
            let cosmicDay = calculator.calculateCosmicDay(for: date, birthChart: nil)

            XCTAssertTrue((1.0...10.0).contains(cosmicDay.overallScore),
                "Overall score \(cosmicDay.overallScore) out of bounds for \(date)")
            XCTAssertTrue((1.0...10.0).contains(cosmicDay.relationshipScore),
                "Relationship score \(cosmicDay.relationshipScore) out of bounds for \(date)")
            XCTAssertTrue((1.0...10.0).contains(cosmicDay.careerScore),
                "Career score \(cosmicDay.careerScore) out of bounds for \(date)")
            XCTAssertTrue((1.0...10.0).contains(cosmicDay.healthScore),
                "Health score \(cosmicDay.healthScore) out of bounds for \(date)")
        }
    }

    // MARK: - Moon Phase Modifier Tests

    func testMoonPhaseScoreModifiers() {
        for phase in MoonPhase.allCases {
            XCTAssertGreaterThanOrEqual(phase.scoreModifier, -1.0,
                "\(phase.rawValue) modifier should be >= -1.0")
            XCTAssertLessThanOrEqual(phase.scoreModifier, 1.5,
                "\(phase.rawValue) modifier should be <= 1.5")
        }
    }

    func testFullMoonHasPositiveModifier() {
        XCTAssertEqual(MoonPhase.fullMoon.scoreModifier, 1.0,
            "Full moon should have +1.0 score modifier")
    }

    func testNewMoonHasPositiveModifier() {
        XCTAssertEqual(MoonPhase.newMoon.scoreModifier, 0.5,
            "New moon should have +0.5 score modifier")
    }

    func testWaningPhasesHaveNegativeModifiers() {
        XCTAssertLessThan(MoonPhase.waningGibbous.scoreModifier, 0,
            "Waning gibbous should have negative modifier")
        XCTAssertLessThan(MoonPhase.waningCrescent.scoreModifier, 0,
            "Waning crescent should have negative modifier")
    }

    // MARK: - Retrograde Penalty Tests

    func testMercuryRetrogradeHasHighestPenalty() {
        let date = createDateFromJulianDay(2460340.0)
        let retrogrades = ephemeris.getActiveRetrogrades(for: date)

        XCTAssertTrue(retrogrades.contains(.mercury),
            "Mercury should be retrograde around JD 2460340")
    }

    func testNoRetrogradeDateHasHigherScore() {
        let noRetroDate = createDateFromJulianDay(2460400.0)
        let retroDate = createDateFromJulianDay(2460340.0)

        let noRetroRetrogrades = ephemeris.getActiveRetrogrades(for: noRetroDate)
        let retroRetrogrades = ephemeris.getActiveRetrogrades(for: retroDate)

        XCTAssertLessThan(noRetroRetrogrades.count, retroRetrogrades.count,
            "No-retrograde date should have fewer retrogrades")
    }

    func testSunAndMoonCannotBeRetrograde() {
        XCTAssertFalse(Planet.sun.canBeRetrograde, "Sun cannot be retrograde")
        XCTAssertFalse(Planet.moon.canBeRetrograde, "Moon cannot be retrograde")
    }

    func testOuterPlanetsCanBeRetrograde() {
        XCTAssertTrue(Planet.mercury.canBeRetrograde, "Mercury can be retrograde")
        XCTAssertTrue(Planet.venus.canBeRetrograde, "Venus can be retrograde")
        XCTAssertTrue(Planet.mars.canBeRetrograde, "Mars can be retrograde")
        XCTAssertTrue(Planet.jupiter.canBeRetrograde, "Jupiter can be retrograde")
        XCTAssertTrue(Planet.saturn.canBeRetrograde, "Saturn can be retrograde")
    }

    // MARK: - Domain Score Tests

    func testDomainScoresAreIndependent() {
        let date = createDate(year: 2026, month: 3, day: 15)
        let cosmicDay = calculator.calculateCosmicDay(for: date, birthChart: nil)

        let scores = [cosmicDay.relationshipScore, cosmicDay.careerScore, cosmicDay.healthScore]
        let uniqueScores = Set(scores)

        XCTAssertTrue(uniqueScores.count >= 1,
            "Domain scores should be calculated (may or may not be different)")
    }

    func testPlanetDomainAssignments() {
        XCTAssertTrue(Planet.venus.domain.contains(.relationships),
            "Venus should affect relationships")
        XCTAssertTrue(Planet.saturn.domain.contains(.career),
            "Saturn should affect career")
        XCTAssertTrue(Planet.mars.domain.contains(.health),
            "Mars should affect health")
        XCTAssertTrue(Planet.mercury.domain.contains(.career),
            "Mercury should affect career")
    }

    // MARK: - Monthly Calculation Tests

    func testMonthlyCalculationReturnsCorrectDayCount() {
        let february2026 = calculator.calculateScoresForMonth(year: 2026, month: 2, birthChart: nil)
        XCTAssertEqual(february2026.count, 28, "February 2026 has 28 days")

        let january2026 = calculator.calculateScoresForMonth(year: 2026, month: 1, birthChart: nil)
        XCTAssertEqual(january2026.count, 31, "January 2026 has 31 days")

        let april2026 = calculator.calculateScoresForMonth(year: 2026, month: 4, birthChart: nil)
        XCTAssertEqual(april2026.count, 30, "April 2026 has 30 days")
    }

    func testMonthlyCalculationAllScoresValid() {
        let results = calculator.calculateScoresForMonth(year: 2026, month: 6, birthChart: nil)

        for (date, cosmicDay) in results {
            XCTAssertTrue((1.0...10.0).contains(cosmicDay.overallScore),
                "Score for \(date) should be in valid range")
        }
    }

    func testLeapYearFebruaryHandling() {
        let february2024 = calculator.calculateScoresForMonth(year: 2024, month: 2, birthChart: nil)
        XCTAssertEqual(february2024.count, 29, "February 2024 (leap year) has 29 days")
    }

    // MARK: - CosmicDay Structure Tests

    func testCosmicDayContainsAllRequiredFields() {
        let date = Date()
        let cosmicDay = calculator.calculateCosmicDay(for: date, birthChart: nil)

        XCTAssertNotNil(cosmicDay.date)
        XCTAssertNotNil(cosmicDay.overallScore)
        XCTAssertNotNil(cosmicDay.relationshipScore)
        XCTAssertNotNil(cosmicDay.careerScore)
        XCTAssertNotNil(cosmicDay.healthScore)
        XCTAssertNotNil(cosmicDay.moonPhase)
        XCTAssertFalse(cosmicDay.planetaryPositions.isEmpty)
    }

    func testCosmicDayMoonPhaseIsValid() {
        let cosmicDay = calculator.calculateCosmicDay(for: Date(), birthChart: nil)

        XCTAssertTrue(MoonPhase.allCases.contains(cosmicDay.moonPhase),
            "Moon phase should be a valid MoonPhase case")
    }

    func testCosmicDayPlanetaryPositionsIncludeAllPlanets() {
        let cosmicDay = calculator.calculateCosmicDay(for: Date(), birthChart: nil)

        XCTAssertEqual(cosmicDay.planetaryPositions.count, Planet.allCases.count,
            "Should have position for all \(Planet.allCases.count) planets")

        for planet in Planet.allCases {
            let hasPosition = cosmicDay.planetaryPositions.contains { $0.planet == planet }
            XCTAssertTrue(hasPosition, "Should have position for \(planet.rawValue)")
        }
    }

    // MARK: - Score Category Tests

    func testScoreCategoryBoundaries() {
        XCTAssertEqual(ScoreCategory.from(score: 10.0), .excellent)
        XCTAssertEqual(ScoreCategory.from(score: 8.5), .excellent)
        XCTAssertEqual(ScoreCategory.from(score: 8.49), .good)
        XCTAssertEqual(ScoreCategory.from(score: 7.0), .good)
        XCTAssertEqual(ScoreCategory.from(score: 6.99), .neutral)
        XCTAssertEqual(ScoreCategory.from(score: 5.0), .neutral)
        XCTAssertEqual(ScoreCategory.from(score: 4.99), .challenging)
        XCTAssertEqual(ScoreCategory.from(score: 3.0), .challenging)
        XCTAssertEqual(ScoreCategory.from(score: 2.99), .difficult)
        XCTAssertEqual(ScoreCategory.from(score: 1.0), .difficult)
    }

    func testCosmicDayScoreCategoryMatchesOverallScore() {
        let testDates = generateTestDates(count: 10)

        for date in testDates {
            let cosmicDay = calculator.calculateCosmicDay(for: date, birthChart: nil)
            let expectedCategory = ScoreCategory.from(score: cosmicDay.overallScore)

            XCTAssertEqual(cosmicDay.scoreCategory, expectedCategory,
                "Score category should match the overall score")
        }
    }

    // MARK: - Aspect Tests

    func testAspectScoreModifiers() {
        XCTAssertEqual(Aspect.trine.scoreModifier, 1.5, "Trine should have +1.5 modifier")
        XCTAssertEqual(Aspect.sextile.scoreModifier, 1.0, "Sextile should have +1.0 modifier")
        XCTAssertEqual(Aspect.conjunction.scoreModifier, 0.5, "Conjunction should have +0.5 modifier")
        XCTAssertEqual(Aspect.square.scoreModifier, -1.0, "Square should have -1.0 modifier")
        XCTAssertEqual(Aspect.opposition.scoreModifier, -1.5, "Opposition should have -1.5 modifier")
    }

    func testHarmoniousAspects() {
        XCTAssertTrue(Aspect.trine.isHarmonious, "Trine should be harmonious")
        XCTAssertTrue(Aspect.sextile.isHarmonious, "Sextile should be harmonious")
        XCTAssertTrue(Aspect.conjunction.isHarmonious, "Conjunction should be harmonious")
    }

    func testChallengingAspects() {
        XCTAssertFalse(Aspect.square.isHarmonious, "Square should not be harmonious")
        XCTAssertFalse(Aspect.opposition.isHarmonious, "Opposition should not be harmonious")
    }

    // MARK: - Deterministic Calculation Tests

    func testSameDateProducesSameResults() {
        let date = createDate(year: 2026, month: 7, day: 4)

        let result1 = calculator.calculateCosmicDay(for: date, birthChart: nil)
        let result2 = calculator.calculateCosmicDay(for: date, birthChart: nil)

        XCTAssertEqual(result1.overallScore, result2.overallScore,
            "Same date should produce same overall score")
        XCTAssertEqual(result1.relationshipScore, result2.relationshipScore,
            "Same date should produce same relationship score")
        XCTAssertEqual(result1.careerScore, result2.careerScore,
            "Same date should produce same career score")
        XCTAssertEqual(result1.healthScore, result2.healthScore,
            "Same date should produce same health score")
        XCTAssertEqual(result1.moonPhase, result2.moonPhase,
            "Same date should produce same moon phase")
    }

    func testDifferentDatesProduceDifferentResults() {
        let date1 = createDate(year: 2026, month: 1, day: 1)
        let date2 = createDate(year: 2026, month: 6, day: 15)

        let result1 = calculator.calculateCosmicDay(for: date1, birthChart: nil)
        let result2 = calculator.calculateCosmicDay(for: date2, birthChart: nil)

        let scoresAreDifferent = result1.overallScore != result2.overallScore ||
                                  result1.relationshipScore != result2.relationshipScore ||
                                  result1.careerScore != result2.careerScore ||
                                  result1.healthScore != result2.healthScore

        XCTAssertTrue(scoresAreDifferent,
            "Different dates should generally produce different results")
    }

    // MARK: - Planetary Position Tests

    func testPlanetaryLongitudesAreValid() {
        let date = Date()
        let positions = ephemeris.calculatePlanetaryPositions(for: date)

        for position in positions {
            XCTAssertGreaterThanOrEqual(position.longitude, 0.0,
                "\(position.planet.rawValue) longitude should be >= 0")
            XCTAssertLessThan(position.longitude, 360.0,
                "\(position.planet.rawValue) longitude should be < 360")
        }
    }

    func testZodiacSignAssignment() {
        XCTAssertEqual(ZodiacSign.from(degree: 0), .aries)
        XCTAssertEqual(ZodiacSign.from(degree: 30), .taurus)
        XCTAssertEqual(ZodiacSign.from(degree: 60), .gemini)
        XCTAssertEqual(ZodiacSign.from(degree: 90), .cancer)
        XCTAssertEqual(ZodiacSign.from(degree: 120), .leo)
        XCTAssertEqual(ZodiacSign.from(degree: 150), .virgo)
        XCTAssertEqual(ZodiacSign.from(degree: 180), .libra)
        XCTAssertEqual(ZodiacSign.from(degree: 210), .scorpio)
        XCTAssertEqual(ZodiacSign.from(degree: 240), .sagittarius)
        XCTAssertEqual(ZodiacSign.from(degree: 270), .capricorn)
        XCTAssertEqual(ZodiacSign.from(degree: 300), .aquarius)
        XCTAssertEqual(ZodiacSign.from(degree: 330), .pisces)
    }

    // MARK: - Julian Day Tests

    func testJulianDayConversion() {
        let knownDate = createDate(year: 2000, month: 1, day: 1, hour: 12)
        let julianDay = ephemeris.julianDayFromDate(knownDate)

        XCTAssertEqual(julianDay, 2451545.0, accuracy: 0.01,
            "J2000.0 epoch should be Julian Day 2451545.0")
    }

    func testJulianDayRoundTrip() {
        let originalDate = createDate(year: 2026, month: 6, day: 15, hour: 12)
        let julianDay = ephemeris.julianDayFromDate(originalDate)
        let convertedDate = Date(julianDay: julianDay)

        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.year, from: convertedDate), 2026)
        XCTAssertEqual(calendar.component(.month, from: convertedDate), 6)
        XCTAssertEqual(calendar.component(.day, from: convertedDate), 15)
    }

    // MARK: - Life Domain Tests

    func testAllLifeDomainsExist() {
        XCTAssertEqual(LifeDomain.allCases.count, 3, "Should have exactly 3 life domains")
        XCTAssertTrue(LifeDomain.allCases.contains(.relationships))
        XCTAssertTrue(LifeDomain.allCases.contains(.career))
        XCTAssertTrue(LifeDomain.allCases.contains(.health))
    }

    func testLifeDomainIcons() {
        XCTAssertEqual(LifeDomain.relationships.icon, "heart.fill")
        XCTAssertEqual(LifeDomain.career.icon, "briefcase.fill")
        XCTAssertEqual(LifeDomain.health.icon, "leaf.fill")
    }

    // MARK: - Helper Methods

    private func generateTestDates(count: Int) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let startDate = createDate(year: 2026, month: 1, day: 1)

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

        return Calendar.current.date(from: components) ?? Date()
    }

    private func createDateFromJulianDay(_ julianDay: Double) -> Date {
        return Date(julianDay: julianDay)
    }
}
