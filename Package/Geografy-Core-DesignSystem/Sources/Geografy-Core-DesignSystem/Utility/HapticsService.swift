#if os(iOS)
import UIKit
#endif
import Foundation
import Observation

#if !os(iOS)
public enum HapticImpactStyle {
    case light
    case medium
    case heavy
    case soft
    case rigid
}

public enum HapticNotificationType {
    case success
    case warning
    case error
}
#else
public typealias HapticImpactStyle = UIImpactFeedbackGenerator.FeedbackStyle
public typealias HapticNotificationType = UINotificationFeedbackGenerator.FeedbackType
#endif

/// Plays the app's haptics. One rule keeps them consistent:
/// - Taps are `.light`. Buttons styled with `PressButtonStyle` already play it on press, so don't add another.
/// - Picking an item on a map or in a list is `selection()`.
/// - Saving or finishing something is `notification(.success)`; a wrong answer is `notification(.error)`.
/// - `.medium` and heavier are for game moments only, such as finding a word.
@Observable
@MainActor
public final class HapticsService {
    public init() {}

    #if os(iOS)
    public func impact(_ style: HapticImpactStyle) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    /// An impact at a fraction of the style's full strength, from 0 to 1.
    public func impact(_ style: HapticImpactStyle, intensity: CGFloat) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred(intensity: intensity)
    }

    public func notification(_ type: HapticNotificationType) {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    public func selection() {
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    #else
    public func impact(_ style: HapticImpactStyle) {}
    public func impact(_ style: HapticImpactStyle, intensity: CGFloat) {}
    public func notification(_ type: HapticNotificationType) {}
    public func selection() {}
    #endif
}

// MARK: - Helpers
private extension HapticsService {
    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true
    }
}
