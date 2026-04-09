import Lottie
import SwiftUI

/// Catalog of well-known Lottie animations bundled with the design system.
/// Using the enum rather than raw strings prevents typos at call sites and
/// makes asset audits trivial.
public enum GeoLottie: String, CaseIterable, Sendable {
    case unlockConfetti = "unlock-confetti"
    case levelUpStarburst = "level-up-starburst"
    case streakFlame = "streak-flame"
    case checkmarkSuccess = "checkmark-success"
    case xmarkWrong = "xmark-wrong"
    case emptyStateGlobe = "empty-state-globe"

    public var resourceName: String { rawValue }
}

/// SwiftUI wrapper for a Lottie animation with mandatory Reduce-Motion fallback.
/// Falls back to the provided static view when the JSON is missing, Lottie fails
/// to decode, or the user has Reduce Motion enabled — so the UI always resolves
/// to something meaningful.
public struct GeoLottieView<Fallback: View>: View {
    private let animation: GeoLottie
    private let loopMode: LottieLoopMode
    private let animationSpeed: CGFloat
    private let fallback: Fallback

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        _ animation: GeoLottie,
        loopMode: LottieLoopMode = .playOnce,
        speed: CGFloat = 1,
        @ViewBuilder fallback: () -> Fallback
    ) {
        self.animation = animation
        self.loopMode = loopMode
        self.animationSpeed = speed
        self.fallback = fallback()
    }

    public var body: some View {
        if reduceMotion {
            fallback
        } else if let resolved = Self.loadAnimation(animation) {
            LottieView(animation: resolved)
                .playing(loopMode: loopMode)
                .animationSpeed(animationSpeed)
        } else {
            fallback
        }
    }
}

// MARK: - Helpers
private extension GeoLottieView {
    static func loadAnimation(_ animation: GeoLottie) -> LottieAnimation? {
        guard let url = Bundle.module.url(
            forResource: animation.resourceName,
            withExtension: "json",
            subdirectory: "Lottie"
        ) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(LottieAnimation.self, from: data)
    }
}
