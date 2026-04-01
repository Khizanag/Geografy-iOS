#if os(iOS)
import UIKit
#endif
import Foundation
import Observation

@Observable
@MainActor
public final class HapticsService {
    public init() {}

    #if os(iOS)
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    public func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    public func selection() {
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    #else
    public func impact(_ style: Any) {}
    public func notification(_ type: Any) {}
    public func selection() {}
    #endif
}

// MARK: - Helpers
private extension HapticsService {
    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true
    }
}
