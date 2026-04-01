import Foundation
import Geografy_Core_Common

@Observable
public final class TestingModeService {
    private static let storageKey = "testing_mode_enabled"

    public var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.storageKey)
        }
    }

    public init() {
        isEnabled = UserDefaults.standard.bool(forKey: Self.storageKey)
    }
}
