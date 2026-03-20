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
            VStack(spacing: GeoSpacing.md) {
                accountSection
                generalSettingsSection
                gameSettingsSection
                soundAndVibrationSection
            }
            .padding(.horizontal, GeoSpacing.md)
            .padding(.vertical, GeoSpacing.sm)
        }
        .background(GeoColors.background)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(GeoColors.background, for: .navigationBar)
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
                HStack(spacing: GeoSpacing.sm) {
                    avatarPlaceholder
                    VStack(alignment: .leading, spacing: GeoSpacing.xxs) {
                        Text("Guest")
                            .font(GeoFont.headline)
                            .foregroundStyle(GeoColors.textPrimary)
                        Text("Account settings")
                            .font(GeoFont.caption)
                            .foregroundStyle(GeoColors.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(GeoFont.caption)
                        .foregroundStyle(GeoColors.textTertiary)
                }
                .padding(GeoSpacing.md)
            }
            .buttonStyle(.plain)
        }
    }

    var avatarPlaceholder: some View {
        Circle()
            .fill(GeoColors.cardBackgroundHighlighted)
            .frame(width: 48, height: 48)
            .overlay {
                Image(systemName: "person.fill")
                    .font(GeoFont.title2)
                    .foregroundStyle(GeoColors.textSecondary)
            }
    }

    var generalSettingsSection: some View {
        settingsGroup(header: "General settings") {
            SettingsToggleRow(
                icon: "bell.fill",
                iconColor: GeoColors.accent,
                title: "Notifications",
                isOn: $notificationsEnabled,
            )

            settingsDivider

            SettingsNavigationRow(
                icon: "exclamationmark.triangle.fill",
                iconColor: GeoColors.warning,
                title: "Territorial disputes",
                comingSoon: true
            ) {}

            settingsDivider

            SettingsNavigationRow(
                icon: "square.grid.2x2.fill",
                iconColor: Color(hex: "5C6BC0"),
                title: "Manage additions",
                comingSoon: true
            ) {}

            settingsDivider

            SettingsNavigationRow(
                icon: "globe",
                iconColor: Color(hex: "3498DB"),
                title: "Change language",
                value: selectedLanguage,
                comingSoon: true
            ) {}

            settingsDivider

            SettingsNavigationRow(
                icon: "paintbrush.fill",
                iconColor: Color(hex: "9B59B6"),
                title: "Theme",
                value: selectedTheme,
                comingSoon: true
            ) {}

            settingsDivider

            SettingsNavigationRow(
                icon: "arrow.up.arrow.down",
                iconColor: GeoColors.textSecondary,
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
                iconColor: GeoColors.success,
                title: "Show correct answer",
                isOn: $showCorrectAnswer,
            )

            settingsDivider

            SettingsToggleRow(
                icon: "eye.slash.fill",
                iconColor: GeoColors.textSecondary,
                title: "Hide dependent territories",
                isOn: $hideDependentTerritories,
            )
        }
    }

    var soundAndVibrationSection: some View {
        settingsGroup(header: "Sound and vibration") {
            SettingsToggleRow(
                icon: "iphone.radiowaves.left.and.right",
                iconColor: GeoColors.accent,
                title: "Vibration",
                isOn: $vibrationEnabled,
            )

            settingsDivider

            SettingsToggleRow(
                icon: "speaker.wave.2.fill",
                iconColor: Color(hex: "E67E22"),
                title: "Sound effects",
                isOn: $soundEffectsEnabled,
            )
        }
    }

    var settingsDivider: some View {
        Divider()
            .background(GeoColors.cardBackgroundHighlighted)
            .padding(.leading, GeoSpacing.xxl)
    }
}

// MARK: - Helpers

private extension SettingsScreen {
    func settingsGroup(header: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: GeoSpacing.xs) {
            Text(header.uppercased())
                .font(GeoFont.caption)
                .foregroundStyle(GeoColors.textTertiary)
                .padding(.horizontal, GeoSpacing.xs)

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
        HStack(spacing: GeoSpacing.sm) {
            SettingsIconBadge(systemImage: icon, color: iconColor)

            Text(title)
                .font(GeoFont.body)
                .foregroundStyle(GeoColors.textPrimary)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(GeoColors.success)
        }
        .padding(.horizontal, GeoSpacing.md)
        .padding(.vertical, GeoSpacing.sm)
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
            HStack(spacing: GeoSpacing.sm) {
                SettingsIconBadge(systemImage: icon, color: iconColor)

                Text(title)
                    .font(GeoFont.body)
                    .foregroundStyle(GeoColors.textPrimary)

                Spacer()

                if comingSoon {
                    Text("Soon")
                        .font(GeoFont.caption2)
                        .foregroundStyle(GeoColors.textTertiary)
                        .padding(.horizontal, GeoSpacing.xs)
                        .padding(.vertical, GeoSpacing.xxs)
                        .background(GeoColors.cardBackgroundHighlighted)
                        .clipShape(Capsule())
                } else if let value {
                    Text(value)
                        .font(GeoFont.subheadline)
                        .foregroundStyle(GeoColors.textSecondary)
                }

                Image(systemName: "chevron.right")
                    .font(GeoFont.caption)
                    .foregroundStyle(GeoColors.textTertiary)
            }
            .padding(.horizontal, GeoSpacing.md)
            .padding(.vertical, GeoSpacing.sm)
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
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 28, height: 28)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: GeoCornerRadius.small))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsScreen()
    }
}
