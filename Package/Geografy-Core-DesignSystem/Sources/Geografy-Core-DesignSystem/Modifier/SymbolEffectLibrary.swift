import SwiftUI

/// Named symbol-effect presets used across the app. Keeps call sites terse
/// and makes it trivial to audit where each effect fires.
///
/// Example:
/// ```swift
/// Image(systemName: "star.fill")
///     .geoEffect(.favoriteTap(isFavorite: isFavorite))
/// ```
public extension View {
    func geoEffect(_ effect: GeoSymbolEffect) -> some View {
        modifier(GeoSymbolEffectModifier(effect: effect))
    }
}

// Symbol effects are decoration, so they stop entirely under Reduce Motion.
private struct GeoSymbolEffectModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let effect: GeoSymbolEffect

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.applying(effect)
        }
    }
}

private extension View {
    @ViewBuilder
    func applying(_ effect: GeoSymbolEffect) -> some View {
        switch effect {
        case .favoriteTap(let isFavorite):
            symbolEffect(.bounce, value: isFavorite)
        case .tabSelect(let trigger):
            symbolEffect(.bounce, value: trigger)
        case .streakIncrement(let count):
            symbolEffect(.bounce.up, options: .nonRepeating, value: count)
        case .unlockPop(let trigger):
            symbolEffect(.bounce.up, options: .speed(1.3), value: trigger)
        case .correctBounce(let trigger):
            symbolEffect(.bounce, options: .speed(1.2), value: trigger)
        case .wrongShake(let trigger):
            symbolEffect(.wiggle, options: .nonRepeating, value: trigger)
        case .scanning(let isActive):
            symbolEffect(.variableColor.iterative, options: .repeating, isActive: isActive)
        case .pulse(let trigger):
            symbolEffect(.pulse, options: .nonRepeating, value: trigger)
        }
    }
}

/// Library of intent-named symbol effects. Each case carries the trigger value
/// so call sites read naturally.
public enum GeoSymbolEffect {
    case favoriteTap(isFavorite: Bool)
    case tabSelect(trigger: Int)
    case streakIncrement(count: Int)
    case unlockPop(trigger: Int)
    case correctBounce(trigger: Int)
    case wrongShake(trigger: Int)
    case scanning(isActive: Bool)
    case pulse(trigger: Int)
}
