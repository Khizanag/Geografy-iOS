import SwiftUI

extension View {
    @ViewBuilder
    func featureFlag(_ flag: FeatureFlag) -> some View {
        if FeatureFlagService.shared.isEnabled(flag) {
            self
        }
    }
}
