import Observation

/// Everything is unlocked until monetization is decided. This is the single
/// place to reintroduce gating: features read `isPremium` from here, never
/// from a store or purchase API directly.
@MainActor
@Observable
public final class EntitlementService {
    public private(set) var isPremium = true

    public init() {}
}
