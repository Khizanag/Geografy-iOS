import Foundation
import Geografy_Core_Common

/// Shows test checklists on hub tiles and a test sign-in. Debug builds only: in a release build it's always off.
@Observable
public final class TestingModeService {
    private static let storageKey = "testing_mode_enabled"

    public var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.storageKey)
        }
    }

    public init() {
        #if DEBUG
        isEnabled = UserDefaults.standard.bool(forKey: Self.storageKey)
        #else
        isEnabled = false
        #endif
    }
}
