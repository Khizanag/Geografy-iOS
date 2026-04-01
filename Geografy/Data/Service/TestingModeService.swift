import Foundation
import Geografy_Core_Common

@Observable
final class TestingModeService {
    private static let storageKey = "testing_mode_enabled"

    var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.storageKey)
        }
    }

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: Self.storageKey)
    }
}
