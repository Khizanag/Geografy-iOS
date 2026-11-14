import SwiftUI

/// The small uppercase label above a group of rows or a value.
public struct EyebrowLabel: View {
    // MARK: - Properties
    @Environment(\.locale) private var locale

    private let title: Text
    private let color: Color

    // MARK: - Init
    public init(_ title: LocalizedStringKey, color: Color = DesignSystem.Color.textSecondary) {
        self.title = Text(title)
        self.color = color
    }

    /// A title that's already in the reader's language, such as a name.
    @_disfavoredOverload
    public init(_ title: some StringProtocol, color: Color = DesignSystem.Color.textSecondary) {
        self.title = Text(title)
        self.color = color
    }

    // MARK: - Body
    public var body: some View {
        title
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .textCase(writesInCapitals ? .uppercase : nil)
            .kerning(1.2)
            .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Helpers
private extension EyebrowLabel {
    /// Georgian's capitals, Mtavruli, aren't used for labels, so Georgian text keeps its usual letters.
    var writesInCapitals: Bool {
        locale.language.languageCode != Locale.LanguageCode("ka")
    }
}
