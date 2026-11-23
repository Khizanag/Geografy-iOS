import Geografy_Core_Common
import Geografy_Core_DesignSystem
import Geografy_Core_Service
import SwiftUI

/// The app language picker, shown once a second language ships, and a way to set it in iOS Settings.
struct SettingsLanguageSection: View {
    // MARK: - Properties
    @Environment(LanguageService.self) private var languageService
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    // MARK: - Body
    var body: some View {
        if languageService.isChoosable {
            SettingsGroup("Language") {
                VStack(spacing: 0) {
                    languageRow
                    // Read on every return to the app, so a language added in iOS Settings shows the row.
                    if scenePhase == .active, languageService.isChoosableInSystemSettings {
                        SettingsDivider()
                        systemLanguageRow
                    }
                }
            }
        }
    }
}

// MARK: - Subviews
private extension SettingsLanguageSection {
    var languageRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            SettingsIconBadge(systemImage: "globe", color: DesignSystem.Color.blue)
            Text("App language")
                .font(DesignSystem.Font.body)
                .foregroundStyle(DesignSystem.Color.textPrimary)
            Spacer()
            MenuPicker(
                "App language",
                selection: languageSelection,
                selectedTitle: languageTitle(languageService.language)
            ) {
                ForEach(languageService.languages) { language in
                    languageTitle(language).tag(language)
                }
            }
        }
        .settingsRowPadding()
        .haptic(.selection, trigger: languageService.language)
    }

    /// Opens Geografy's page in iOS Settings, where its language can be set as well.
    var systemLanguageRow: some View {
        Button(action: openAppSettings) {
            SettingsExternalRow(
                icon: "gearshape.fill",
                iconColor: DesignSystem.Color.textSecondary,
                title: "Language in iOS Settings"
            )
        }
        .buttonStyle(PressButtonStyle())
        .accessibilityHint("Opens Geografy's page in the Settings app")
    }

    func languageTitle(_ language: AppLanguage) -> Text {
        Text(verbatim: "\(language.flagEmoji) \(language.endonym)")
    }

    var languageSelection: Binding<AppLanguage> {
        Binding {
            languageService.language
        } set: { language in
            guard language != languageService.language else { return }
            languageService.language = language
        }
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        openURL(url)
    }
}
