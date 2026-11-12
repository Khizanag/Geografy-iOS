import SwiftUI

/// A menu picker whose button shows only the selected title, while the menu items keep their icons.
public struct MenuPicker<Value: Hashable, Items: View>: View {
    // MARK: - Properties
    private let title: LocalizedStringKey
    private let selectedTitle: Text
    @Binding private var selection: Value
    private let items: Items

    // MARK: - Init
    public init(
        _ title: LocalizedStringKey,
        selection: Binding<Value>,
        selectedTitle: Text,
        @ViewBuilder items: () -> Items
    ) {
        self.title = title
        self.selectedTitle = selectedTitle
        self._selection = selection
        self.items = items()
    }

    // MARK: - Body
    public var body: some View {
        Menu {
            Picker(title, selection: $selection) {
                items
            }
        } label: {
            HStack(spacing: DesignSystem.Spacing.xxs) {
                selectedTitle
                Image(systemName: "chevron.up.chevron.down")
                    .font(DesignSystem.Font.caption2)
                    .fontWeight(.semibold)
                    .accessibilityHidden(true)
            }
            .foregroundStyle(DesignSystem.Color.textPrimary)
        }
        .tint(DesignSystem.Color.iconPrimary)
        .accessibilityLabel(Text(title))
        .accessibilityValue(selectedTitle)
    }
}
