import SwiftUI

struct SpeakerButton: View {
    @Environment(PronunciationService.self) private var pronunciationService

    let text: String
    let countryCode: String

    private var isActivelySpeaking: Bool {
        pronunciationService.isCurrentlySpeaking(text: text)
    }

    var body: some View {
        Button {
            if isActivelySpeaking {
                pronunciationService.stop()
            } else {
                pronunciationService.speak(text: text, countryCode: countryCode)
            }
        } label: {
            Image(systemName: isActivelySpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
                .font(DesignSystem.Font.footnote.weight(.medium))
                .foregroundStyle(
                    isActivelySpeaking
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textSecondary
                )
                .symbolEffect(.variableColor.iterative.reversing, isActive: isActivelySpeaking)
                .frame(width: 44, height: 44)
        }
        .glassEffect(.regular.interactive(), in: .circle)
        .buttonStyle(.plain)
        .accessibilityLabel(isActivelySpeaking ? "Stop pronunciation" : "Pronounce \(text)")
    }
}
