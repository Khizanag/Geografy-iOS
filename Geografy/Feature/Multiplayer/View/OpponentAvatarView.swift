import GeografyDesign
import SwiftUI

struct OpponentAvatarView: View {
    let opponent: MockOpponent
    let size: CGFloat
    let showFlag: Bool

    init(
        opponent: MockOpponent,
        size: CGFloat = DesignSystem.Size.xl,
        showFlag: Bool = true
    ) {
        self.opponent = opponent
        self.size = size
        self.showFlag = showFlag
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ProfileAvatarView(name: opponent.name, size: size)

            if showFlag {
                flagBadge
            }
        }
    }
}

// MARK: - Subviews
private extension OpponentAvatarView {
    var flagBadge: some View {
        FlagView(countryCode: opponent.countryCode, height: size * 0.35)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(DesignSystem.Color.cardBackground, lineWidth: 2)
            )
            .offset(x: size * 0.1, y: size * 0.1)
    }
}
