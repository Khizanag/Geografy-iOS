import Geografy_Core_DesignSystem
import SwiftUI

public struct OpponentAvatarView: View {
    public let opponent: MockOpponent
    public let size: CGFloat
    public let showFlag: Bool

    public init(
        opponent: MockOpponent,
        size: CGFloat = DesignSystem.Size.xl,
        showFlag: Bool = true
    ) {
        self.opponent = opponent
        self.size = size
        self.showFlag = showFlag
    }

    public var body: some View {
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
