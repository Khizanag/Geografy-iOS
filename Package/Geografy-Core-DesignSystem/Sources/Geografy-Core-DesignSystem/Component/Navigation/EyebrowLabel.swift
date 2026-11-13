import SwiftUI

/// The small uppercase label above a group of rows or a value.
public struct EyebrowLabel: View {
    // MARK: - Properties
    private let title: String
    private let color: Color

    // MARK: - Init
    public init(_ title: String, color: Color = DesignSystem.Color.textSecondary) {
        self.title = title
        self.color = color
    }

    // MARK: - Body
    public var body: some View {
        Text(title)
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .textCase(.uppercase)
            .kerning(1.2)
            .accessibilityAddTraits(.isHeader)
    }
}
