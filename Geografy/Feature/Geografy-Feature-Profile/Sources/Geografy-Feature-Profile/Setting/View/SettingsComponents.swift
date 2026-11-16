import Foundation
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - URLs
enum SettingsURLs {
    static let appStore = URL(string: "https://apps.apple.com/app/geografy/id6743292498")!
    static let privacy = URL(string: "https://khizanag.github.io/geografy/privacy")!
    static let terms = URL(string: "https://khizanag.github.io/geografy/terms")!
}

// MARK: - Toggle Row
struct SettingsToggleRow: View {
    // MARK: - Properties
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    @Binding var isOn: Bool

    // MARK: - Body
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(DesignSystem.Color.accent)
        }
        .settingsRowPadding()
    }
}

// MARK: - Navigation Row
struct SettingsNavigationRow: View {
    // MARK: - Properties
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey

    // MARK: - Body
    var body: some View {
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
struct SettingsExternalRow: View {
    // MARK: - Properties
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey

    // MARK: - Body
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Image(systemName: "arrow.up.forward")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .settingsRowPadding()
        .contentShape(Rectangle())
    }
}

// MARK: - Divider
/// The line between two rows in a settings card, starting past the icons.
struct SettingsDivider: View {
    var body: some View {
        Divider()
            .background(DesignSystem.Color.cardBackgroundHighlighted)
            .padding(.leading, DesignSystem.Spacing.xxl + DesignSystem.Spacing.md)
    }
}

// MARK: - Row Padding
extension View {
    func settingsRowPadding() -> some View {
        self
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
    }
}
