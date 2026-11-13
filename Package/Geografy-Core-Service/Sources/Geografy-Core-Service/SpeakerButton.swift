#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

public struct SpeakerButton: View {
    // MARK: - Properties
    /// The regular button's width and height, for layouts that balance it.
    nonisolated public static let size: CGFloat = 32

    public enum Size {
        case regular
        /// For tight spots such as a fact tile's corner.
        case compact

        var diameter: CGFloat {
            switch self {
            case .regular: SpeakerButton.size
            case .compact: 24
            }
        }
    }

    @Environment(PronunciationService.self) private var pronunciationService

    public let text: String
    public let countryCode: String
    public let buttonSize: Size

    // MARK: - Init
    public init(text: String, countryCode: String, size: Size = .regular) {
        self.text = text
        self.countryCode = countryCode
        self.buttonSize = size
    }

    private var isActivelySpeaking: Bool {
        pronunciationService.isCurrentlySpeaking(text: text)
    }

    // MARK: - Body
    public var body: some View {
        Button {
            if isActivelySpeaking {
                pronunciationService.stop()
            } else {
                pronunciationService.speak(text: text, countryCode: countryCode)
            }
        } label: {
            Image(systemName: isActivelySpeaking ? "speaker.wave.3.fill" : "speaker.wave.2")
                .font(DesignSystem.Font.caption2.weight(.medium))
                .foregroundStyle(
                    isActivelySpeaking
                        ? DesignSystem.Color.accent
                        : DesignSystem.Color.textSecondary
                )
                .symbolEffect(.variableColor.iterative.reversing, isActive: isActivelySpeaking)
                .frame(width: buttonSize.diameter, height: buttonSize.diameter)
        }
        .glassEffect(.regular.interactive(), in: .circle)
        .buttonStyle(.plain)
        .accessibilityLabel(isActivelySpeaking ? "Stop pronunciation" : "Pronounce \(text)")
    }
}
#endif
