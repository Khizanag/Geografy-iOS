#if !os(tvOS)
import Geografy_Core_DesignSystem
import SwiftUI

public struct SpeakerButton: View {
    // MARK: - Properties
    public enum Size {
        case regular
        /// For tight spots such as a fact tile's corner.
        case compact

        var diameter: CGFloat {
            switch self {
            case .regular: 32
            case .compact: 24
            }
        }
    }

    public enum Backing {
        case glass
        /// A plain tinted circle, for content that turns or tilts, where glass would draw apart from it.
        case fill
    }

    // The glyph stops growing at xxxLarge, so the circle stops there too.
    private static let maximumScale: CGFloat = 1.6

    @Environment(PronunciationService.self) private var pronunciationService

    public let text: String
    public let countryCode: String
    public let buttonSize: Size
    public let backing: Backing
    @ScaledMetric private var diameter: CGFloat

    // MARK: - Init
    public init(text: String, countryCode: String, size: Size = .regular, backing: Backing = .glass) {
        self.text = text
        self.countryCode = countryCode
        self.buttonSize = size
        self.backing = backing
        _diameter = ScaledMetric(wrappedValue: size.diameter, relativeTo: .caption2)
    }

    private var circleDiameter: CGFloat {
        min(diameter, buttonSize.diameter * Self.maximumScale)
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
                        : DesignSystem.Color.iconPrimary
                )
                .symbolEffect(.variableColor.iterative.reversing, isActive: isActivelySpeaking)
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .frame(width: circleDiameter, height: circleDiameter)
        }
        .modifier(SpeakerBacking(backing: backing))
        .buttonStyle(.plain)
        .accessibilityLabel(isActivelySpeaking ? "Stop pronunciation" : "Pronounce \(text)")
    }
}

private struct SpeakerBacking: ViewModifier {
    let backing: SpeakerButton.Backing

    func body(content: Content) -> some View {
        switch backing {
        case .glass:
            content.glassEffect(.regular.interactive(), in: .circle)
        case .fill:
            content.background(DesignSystem.Color.iconPrimary.opacity(DesignSystem.Opacity.faint), in: .circle)
        }
    }
}
#endif
