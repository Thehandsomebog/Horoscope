import SwiftUI

// MARK: - Dynamic Type Support

/// Custom font sizes that scale with Dynamic Type settings
struct CosmicTypography {
    // Title fonts with serif design - scale with Dynamic Type
    static let largeTitle = Font.system(.largeTitle, design: .serif, weight: .bold)
    static let title1 = Font.system(.title, design: .serif, weight: .bold)
    static let title2 = Font.system(.title2, design: .serif, weight: .semibold)
    static let title3 = Font.system(.title3, design: .serif, weight: .semibold)

    // Body fonts - scale with Dynamic Type
    static let headline = Font.headline
    static let subheadline = Font.subheadline

    static let body = Font.body
    static let bodyBold = Font.body.weight(.semibold)

    static let callout = Font.callout
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2

    // Custom display fonts - use scaledFont for accessibility
    static func cosmicScore(relativeTo textStyle: Font.TextStyle = .largeTitle) -> Font {
        .system(.largeTitle, design: .rounded, weight: .light)
    }

    static func zodiacSymbol(relativeTo textStyle: Font.TextStyle = .title) -> Font {
        .system(.title, design: .serif, weight: .regular)
    }

    static func planetSymbol(relativeTo textStyle: Font.TextStyle = .title2) -> Font {
        .system(.title2, design: .serif, weight: .regular)
    }

    static func moonPhase(relativeTo textStyle: Font.TextStyle = .largeTitle) -> Font {
        .system(.largeTitle, design: .default, weight: .regular)
    }

    // Large display fonts for decorative elements
    static let displayLarge = Font.system(.largeTitle, design: .rounded, weight: .ultraLight)
    static let displayMedium = Font.system(.title, design: .rounded, weight: .light)
    static let displaySmall = Font.system(.title2, design: .rounded, weight: .light)

    // Legacy static fonts for backwards compatibility (deprecated)
    @available(*, deprecated, message: "Use dynamic font variant instead")
    static let cosmicScoreFixed = Font.system(size: 56, weight: .light, design: .rounded)
    @available(*, deprecated, message: "Use dynamic font variant instead")
    static let zodiacSymbolFixed = Font.system(size: 32, weight: .regular, design: .serif)
    @available(*, deprecated, message: "Use dynamic font variant instead")
    static let planetSymbolFixed = Font.system(size: 24, weight: .regular, design: .serif)
    @available(*, deprecated, message: "Use dynamic font variant instead")
    static let moonPhaseFixed = Font.system(size: 48, weight: .regular, design: .default)
}

// MARK: - Scaled Metric for Custom Sizes

/// A view modifier that scales a custom font size with Dynamic Type
struct ScaledFontModifier: ViewModifier {
    @ScaledMetric var size: CGFloat
    var weight: Font.Weight
    var design: Font.Design

    init(size: CGFloat, relativeTo textStyle: Font.TextStyle = .body, weight: Font.Weight = .regular, design: Font.Design = .default) {
        self._size = ScaledMetric(wrappedValue: size, relativeTo: textStyle)
        self.weight = weight
        self.design = design
    }

    func body(content: Content) -> some View {
        content.font(.system(size: size, weight: weight, design: design))
    }
}

extension View {
    /// Apply a custom font size that scales with Dynamic Type
    func scaledFont(size: CGFloat, relativeTo textStyle: Font.TextStyle = .body, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        modifier(ScaledFontModifier(size: size, relativeTo: textStyle, weight: weight, design: design))
    }
}

// MARK: - Typography View Extensions

extension View {
    func cosmicLargeTitle() -> some View {
        self.font(CosmicTypography.largeTitle)
            .foregroundColor(CosmicColors.text)
    }

    func cosmicTitle() -> some View {
        self.font(CosmicTypography.title1)
            .foregroundColor(CosmicColors.text)
    }

    func cosmicTitle2() -> some View {
        self.font(CosmicTypography.title2)
            .foregroundColor(CosmicColors.text)
    }

    func cosmicTitle3() -> some View {
        self.font(CosmicTypography.title3)
            .foregroundColor(CosmicColors.text)
    }

    func cosmicHeadline() -> some View {
        self.font(CosmicTypography.headline)
            .foregroundColor(CosmicColors.text)
    }

    func cosmicBody() -> some View {
        self.font(CosmicTypography.body)
            .foregroundColor(CosmicColors.text)
    }

    func cosmicSubheadline() -> some View {
        self.font(CosmicTypography.subheadline)
            .foregroundColor(CosmicColors.textSecondary)
    }

    func cosmicCaption() -> some View {
        self.font(CosmicTypography.caption)
            .foregroundColor(CosmicColors.textSecondary)
    }

    func cosmicScore() -> some View {
        self.font(CosmicTypography.cosmicScore())
            .foregroundColor(CosmicColors.cosmicGold)
    }
}

// MARK: - Minimum Scale Factor Extension

extension View {
    /// Ensures text remains readable at larger Dynamic Type sizes
    func accessibleText(minimumScaleFactor: CGFloat = 0.8) -> some View {
        self.minimumScaleFactor(minimumScaleFactor)
            .lineLimit(nil)
    }
}
