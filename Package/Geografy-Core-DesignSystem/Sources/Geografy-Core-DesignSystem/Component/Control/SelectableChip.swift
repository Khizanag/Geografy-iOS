import SwiftUI

/// A capsule filter chip: accent when selected, card-colored otherwise.
public struct SelectableChip<Icon: View>: View {
    // MARK: - Properties
    private let title: String
    private let isSelected: Bool
    private let action: () -> Void
    private let icon: Icon

    // MARK: - Init
    public init(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void,
        @ViewBuilder icon: () -> Icon
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
        self.icon = icon()
    }

    // MARK: - Body
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                icon
                Text(title)
            }
            .font(DesignSystem.Font.caption)
            .fontWeight(.semibold)
            .foregroundStyle(isSelected ? DesignSystem.Color.onAccent : DesignSystem.Color.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(isSelected ? DesignSystem.Color.accent : DesignSystem.Color.cardBackground, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

public extension SelectableChip where Icon == EmptyView {
    init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.init(title, isSelected: isSelected, action: action) { EmptyView() }
    }
}

public extension SelectableChip where Icon == Image {
    init(_ title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) {
        self.init(title, isSelected: isSelected, action: action) { Image(systemName: systemImage) }
    }
}
