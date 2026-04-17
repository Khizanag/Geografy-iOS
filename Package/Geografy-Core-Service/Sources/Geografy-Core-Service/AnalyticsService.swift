import Foundation
import Observation
import os

/// Abstract analytics sink. Features call ``track(_:)`` with a well-known
/// ``AnalyticsEvent``; the concrete provider decides what to do with it
/// (TelemetryDeck, PostHog, none).
///
/// The default provider logs to `os.Logger` in DEBUG and no-ops in RELEASE.
public protocol AnalyticsProvider: Sendable {
    func track(_ event: AnalyticsEvent)
}

/// Catalog of tracked events. Adding a case here is the first step to wiring
/// a new analytics point — concrete providers receive the typed event.
public enum AnalyticsEvent: Sendable, Equatable {
    case paywallShown(context: String?)
    case paywallPlanSelected(productID: String)
    case paywallPurchaseStarted(productID: String)
    case paywallPurchaseCompleted(productID: String)
    case paywallDismissed(context: String?)
    case quizStarted(kind: String)
    case quizCompleted(kind: String, correct: Int, total: Int, bestStreak: Int)
    case onboardingCompleted(continent: String?, goal: String)
    case streakIncremented(newStreak: Int)
    case achievementUnlocked(id: String)
    case deepLinkOpened(scheme: String, path: String)

    public var name: String {
        switch self {
        case .paywallShown: "paywall_shown"
        case .paywallPlanSelected: "paywall_plan_selected"
        case .paywallPurchaseStarted: "paywall_purchase_started"
        case .paywallPurchaseCompleted: "paywall_purchase_completed"
        case .paywallDismissed: "paywall_dismissed"
        case .quizStarted: "quiz_started"
        case .quizCompleted: "quiz_completed"
        case .onboardingCompleted: "onboarding_completed"
        case .streakIncremented: "streak_incremented"
        case .achievementUnlocked: "achievement_unlocked"
        case .deepLinkOpened: "deep_link_opened"
        }
    }
}

/// Default provider. DEBUG builds log via `os.Logger`; RELEASE builds are
/// silent. Swap in a real provider by instantiating ``AnalyticsService`` with
/// a different ``AnalyticsProvider`` in `GeografyApp`.
public struct ConsoleAnalyticsProvider: AnalyticsProvider {
    private let logger = Logger(subsystem: "com.khizanag.geografy", category: "analytics")

    public init() {}

    public func track(_ event: AnalyticsEvent) {
        #if DEBUG
        let name = event.name
        logger.debug("analytics: \(name, privacy: .public)")
        #endif
    }
}

@Observable
@MainActor
public final class AnalyticsService {
    private let provider: AnalyticsProvider

    public init(provider: AnalyticsProvider = ConsoleAnalyticsProvider()) {
        self.provider = provider
    }

    public func track(_ event: AnalyticsEvent) {
        provider.track(event)
    }
}
