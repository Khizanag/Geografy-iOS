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

@Observable
@MainActor
public final class HapticsService {
    public init() {}

    #if os(iOS)
    public func impact(_ style: HapticImpactStyle) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
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
