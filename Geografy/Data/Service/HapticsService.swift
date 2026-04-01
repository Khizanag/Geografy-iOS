#if os(iOS)
import GeografyCore
import UIKit
#endif
import Foundation
import Observation

@Observable
@MainActor
final class HapticsService {
    #if os(iOS)
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    func selection() {
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
    #else
    func impact(_ style: Any) {}
    func notification(_ type: Any) {}
    func selection() {}
    #endif
}

// MARK: - Helpers
private extension HapticsService {
    var isEnabled: Bool {
        UserDefaults.standard.object(forKey: "hapticFeedbackEnabled") as? Bool ?? true
    }
}
