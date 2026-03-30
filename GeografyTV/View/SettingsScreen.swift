import SwiftUI

struct SettingsScreen: View {
    @AppStorage("hapticFeedbackEnabled") private var hapticFeedback = true
    @AppStorage("soundEffectsEnabled") private var soundEffects = true

    var body: some View {
        Form {
            Section("Preferences") {
                Toggle("Sound Effects", isOn: $soundEffects)
                Toggle("Haptic Feedback", isOn: $hapticFeedback)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
    }
}
