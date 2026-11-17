import SwiftUI

// MARK: - Group
/// A titled card of settings rows, as the system Settings app groups them. Separate rows with
/// ``SettingsDivider``.
public struct SettingsGroup<Content: View>: View {
    // MARK: - Properties
    private let header: LocalizedStringKey
    private let content: Content

    // MARK: - Init
    public init(_ header: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.header = header
        self.content = content()
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            EyebrowLabel(header, color: DesignSystem.Color.textTertiary)
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .accessibilityAddTraits(.isHeader)
            CardView {
                VStack(spacing: 0) {
                    content
                }
            }
        }
    }
}

// MARK: - Toggle Row
public struct SettingsToggleRow: View {
    // MARK: - Properties
    private let icon: String
    private let iconColor: Color
    private let title: LocalizedStringKey
    @Binding private var isOn: Bool

    // MARK: - Init
    public init(icon: String, iconColor: Color, title: LocalizedStringKey, isOn: Binding<Bool>) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self._isOn = isOn
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Toggle(isOn: $isOn) { Text(title) }
                .labelsHidden()
                .tint(DesignSystem.Color.accent)
        }
        .settingsRowPadding()
    }
}

// MARK: - Navigation Row
public struct SettingsNavigationRow: View {
    // MARK: - Properties
    private let icon: String
    private let iconColor: Color
    private let title: LocalizedStringKey

    // MARK: - Init
    public init(icon: String, iconColor: Color, title: LocalizedStringKey) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            RowChevron()
        }
        .settingsRowPadding()
        .contentShape(Rectangle())
    }
}

// MARK: - External Link Row
public struct SettingsExternalRow: View {
    // MARK: - Properties
    private let icon: String
    private let iconColor: Color
    private let title: LocalizedStringKey

    // MARK: - Init
    public init(icon: String, iconColor: Color, title: LocalizedStringKey) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Image(systemName: "arrow.up.forward")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .accessibilityHidden(true)
        }
        .settingsRowPadding()
        .contentShape(Rectangle())
    }
}

// MARK: - Action Row
/// A row that does something on tap rather than opening a screen. A destructive one is red in both icon and
/// title, as in the system Settings app.
public struct SettingsActionRow: View {
    // MARK: - Properties
    private let icon: String
    private let iconColor: Color
    private let title: LocalizedStringKey
    private let isDestructive: Bool

    // MARK: - Init
    /// - Parameter iconColor: Ignored when the row is destructive, which is always red.
    public init(
        icon: String,
        iconColor: Color = DesignSystem.Color.blue,
        title: LocalizedStringKey,
        isDestructive: Bool = false
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.isDestructive = isDestructive
    }

    // MARK: - Body
    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: isDestructive ? DesignSystem.Color.destructive : iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(isDestructive ? DesignSystem.Color.destructive : DesignSystem.Color.textPrimary)
            Spacer()
        }
        .settingsRowPadding()
        .contentShape(Rectangle())
    }
}

// MARK: - Divider
/// The line between two rows in a settings card, starting past the icons.
public struct SettingsDivider: View {
    public init() {}

    public var body: some View {
        Divider()
            .background(DesignSystem.Color.cardBackgroundHighlighted)
            .padding(.leading, DesignSystem.Spacing.xxl + DesignSystem.Spacing.md)
    }
}

// MARK: - Row Padding
public extension View {
    func settingsRowPadding() -> some View {
        self
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
    }
}
