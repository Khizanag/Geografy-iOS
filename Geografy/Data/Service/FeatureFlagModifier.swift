import SwiftUI

private struct FeatureFlagModifier: ViewModifier {
    @Environment(FeatureFlagService.self) private var featureFlags

    let flag: FeatureFlag

    @ViewBuilder
    func body(content: Content) -> some View {
        if featureFlags.isEnabled(flag) {
            content
        }
    }
}

extension View {
    func featureFlag(_ flag: FeatureFlag) -> some View {
        modifier(FeatureFlagModifier(flag: flag))
    }
}
