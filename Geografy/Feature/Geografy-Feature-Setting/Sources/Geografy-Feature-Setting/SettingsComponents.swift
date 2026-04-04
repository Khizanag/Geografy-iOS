import Foundation
import Geografy_Core_DesignSystem
import SwiftUI

// MARK: - URLs
enum SettingsURLs {
    // swiftlint:disable force_unwrapping
    static let appStore = URL(string: "https://apps.apple.com/app/geografy/id6743292498")!
    static let privacy = URL(string: "https://khizanag.github.io/geografy/privacy")!
    static let terms = URL(string: "https://khizanag.github.io/geografy/terms")!
    // swiftlint:enable force_unwrapping
}

// MARK: - Toggle Row
struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var isOn: Bool

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
    let icon: String
    let iconColor: Color
    let title: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
        }
        .settingsRowPadding()
        .contentShape(Rectangle())
    }
}

// MARK: - External Link Row
struct SettingsExternalRow: View {
    let icon: String
    let iconColor: Color
    let title: String

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

// MARK: - Icon Badge
struct SettingsIconBadge: View {
    let systemImage: String
    let color: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(DesignSystem.IconSize.medium)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
            .accessibilityHidden(true)
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
