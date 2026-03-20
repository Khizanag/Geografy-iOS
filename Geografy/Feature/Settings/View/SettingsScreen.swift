import SwiftUI

struct SettingsScreen: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("showCorrectAnswer") private var showCorrectAnswer = true
    @AppStorage("hideDependentTerritories") private var hideDependentTerritories = false
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"

    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.md) {
                accountSection
                generalSettingsSection
                gameSettingsSection
                soundAndVibrationSection
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .background(DesignSystem.Color.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(DesignSystem.Color.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Subviews

private extension SettingsScreen {
    var accountSection: some View {
        GeoCard {
            Button {
                // Account settings — coming soon
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    avatarPlaceholder
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                        Text("Guest")
                            .font(DesignSystem.Font.headline)
                            .foregroundStyle(DesignSystem.Color.textPrimary)
                        Text("Account settings")
                            .font(DesignSystem.Font.caption)
                            .foregroundStyle(DesignSystem.Color.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(DesignSystem.Font.caption)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                }
                .padding(DesignSystem.Spacing.md)
            }
            .buttonStyle(.plain)
        }
    }

    var avatarPlaceholder: some View {
        Circle()
            .fill(DesignSystem.Color.cardBackgroundHighlighted)
            .frame(width: DesignSystem.Size.xxl, height: DesignSystem.Size.xxl)
            .overlay {
                Image(systemName: "person.fill")
                    .font(DesignSystem.Font.title2)
                    .foregroundStyle(DesignSystem.Color.textSecondary)
            }
    }

    var generalSettingsSection: some View {
        settingsGroup(header: "General settings") {
            SettingsToggleRow(
                icon: "bell.fill",
                iconColor: DesignSystem.Color.accent,
                title: "Notifications",
                isOn: $notificationsEnabled,
            )

            settingsDivider

            SettingsNavigationRow(
                icon: "exclamationmark.triangle.fill",
                iconColor: DesignSystem.Color.warning,
                title: "Territorial disputes",
                comingSoon: true
            ) {}

            settingsDivider

            SettingsNavigationRow(
                icon: "square.grid.2x2.fill",
                iconColor: DesignSystem.Color.indigo,
                title: "Manage additions",
                comingSoon: true
            ) {}

            settingsDivider

            SettingsNavigationRow(
                icon: "globe",
                iconColor: DesignSystem.Color.blue,
                title: "Change language",
                value: selectedLanguage,
                comingSoon: true
            ) {}

            settingsDivider

            SettingsNavigationRow(
                icon: "paintbrush.fill",
                iconColor: DesignSystem.Color.purple,
                title: "Theme",
                value: selectedTheme,
                comingSoon: true
            ) {}

            settingsDivider

            SettingsNavigationRow(
                icon: "arrow.up.arrow.down",
                iconColor: DesignSystem.Color.textSecondary,
                title: "Orientation",
                value: "Auto",
                comingSoon: true
            ) {}
        }
    }

    var gameSettingsSection: some View {
        settingsGroup(header: "Game settings") {
            SettingsToggleRow(
                icon: "checkmark.circle.fill",
                iconColor: DesignSystem.Color.success,
                title: "Show correct answer",
                isOn: $showCorrectAnswer,
            )

            settingsDivider

            SettingsToggleRow(
                icon: "eye.slash.fill",
                iconColor: DesignSystem.Color.textSecondary,
                title: "Hide dependent territories",
                isOn: $hideDependentTerritories,
            )
        }
    }

    var soundAndVibrationSection: some View {
        settingsGroup(header: "Sound and vibration") {
            SettingsToggleRow(
                icon: "iphone.radiowaves.left.and.right",
                iconColor: DesignSystem.Color.accent,
                title: "Vibration",
                isOn: $vibrationEnabled,
            )

            settingsDivider

            SettingsToggleRow(
                icon: "speaker.wave.2.fill",
                iconColor: DesignSystem.Color.orange,
                title: "Sound effects",
                isOn: $soundEffectsEnabled,
            )
        }
    }

    var settingsDivider: some View {
        Divider()
            .background(DesignSystem.Color.cardBackgroundHighlighted)
            .padding(.leading, DesignSystem.Spacing.xxl)
    }
}

// MARK: - Helpers

private extension SettingsScreen {
    func settingsGroup(header: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(header.uppercased())
                .font(DesignSystem.Font.caption)
                .foregroundStyle(DesignSystem.Color.textTertiary)
                .padding(.horizontal, DesignSystem.Spacing.xs)

            GeoCard {
                VStack(spacing: 0) {
                    content()
                }
            }
        }
    }
}

// MARK: - Settings Row Components

private struct SettingsToggleRow: View {
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
                .tint(DesignSystem.Color.success)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
    }
}

private struct SettingsNavigationRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var value: String?
    var comingSoon: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                SettingsIconBadge(systemImage: icon, color: iconColor)

                Text(title)
                    .font(DesignSystem.Font.body)
                    .foregroundStyle(DesignSystem.Color.textPrimary)

                Spacer()

                if comingSoon {
                    Text("Soon")
                        .font(DesignSystem.Font.caption2)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                        .padding(.horizontal, DesignSystem.Spacing.xs)
                        .padding(.vertical, DesignSystem.Spacing.xxs)
                        .background(DesignSystem.Color.cardBackgroundHighlighted)
                        .clipShape(Capsule())
                } else if let value {
                    Text(value)
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(DesignSystem.Font.caption)
                    .foregroundStyle(DesignSystem.Color.textTertiary)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .buttonStyle(.plain)
        .disabled(comingSoon)
    }
}

private struct SettingsIconBadge: View {
    let systemImage: String
    let color: Color

    var body: some View {
        Image(systemName: systemImage)
            .font(DesignSystem.IconSize.medium)
            .foregroundStyle(DesignSystem.Color.onAccent)
            .frame(width: DesignSystem.Size.md, height: DesignSystem.Size.md)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.small))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
