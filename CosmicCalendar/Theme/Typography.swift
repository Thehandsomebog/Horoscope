import SwiftUI

struct CosmicTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .serif)
    static let title1 = Font.system(size: 28, weight: .bold, design: .serif)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .serif)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .serif)

    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)

    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)

    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    static let cosmicScore = Font.system(size: 56, weight: .light, design: .rounded)
    static let zodiacSymbol = Font.system(size: 32, weight: .regular, design: .serif)
    static let planetSymbol = Font.system(size: 24, weight: .regular, design: .serif)
    static let moonPhase = Font.system(size: 48, weight: .regular, design: .default)

    static let displayLarge = Font.system(size: 72, weight: .ultraLight, design: .rounded)
    static let displayMedium = Font.system(size: 48, weight: .light, design: .rounded)
    static let displaySmall = Font.system(size: 36, weight: .light, design: .rounded)
}

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
            .foregroundColor(CosmicColors.text.opacity(0.8))
    }

    func cosmicCaption() -> some View {
        self.font(CosmicTypography.caption)
            .foregroundColor(CosmicColors.text.opacity(0.6))
    }

    func cosmicScore() -> some View {
        self.font(CosmicTypography.cosmicScore)
            .foregroundColor(CosmicColors.cosmicGold)
    }
}
