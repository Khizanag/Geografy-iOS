import SwiftUI

/// The small colored square that leads a settings row, with a white symbol: as in the system Settings app, its
/// color tells rows apart at a glance. Red marks a row that deletes something.
public struct SettingsIconBadge: View {
    // MARK: - Properties
    private let systemImage: String
    private let color: Color

    // MARK: - Init
    public init(systemImage: String, color: Color) {
        self.systemImage = systemImage
        self.color = color
    }

    // MARK: - Body
    public var body: some View {
        Image(systemName: systemImage)
            .font(DesignSystem.IconSize.medium)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small, style: .continuous))
            .accessibilityHidden(true)
    }
}
