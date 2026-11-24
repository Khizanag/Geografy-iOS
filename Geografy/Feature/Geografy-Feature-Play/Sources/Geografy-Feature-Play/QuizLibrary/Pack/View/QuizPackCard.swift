import Geografy_Core_DesignSystem
import SwiftUI

/// A pack in the library grid: its category's icon and color, its name, and how far along it is.
public struct QuizPackCard: View {
    // MARK: - Properties
    public let pack: QuizPack
    public let completedLevels: Int
    public let stars: Int
    public let maxStars: Int
    public let isUnlocked: Bool

    // MARK: - Init
    public init(
        pack: QuizPack,
        completedLevels: Int,
        stars: Int,
        maxStars: Int,
        isUnlocked: Bool
    ) {
        self.pack = pack
        self.completedLevels = completedLevels
        self.stars = stars
        self.maxStars = maxStars
        self.isUnlocked = isUnlocked
    }

    // MARK: - Body
    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(alignment: .top) {
                IconBadge(pack.icon, color: pack.color, size: .medium)
                Spacer(minLength: 0)
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(DesignSystem.Font.subheadline)
                        .foregroundStyle(DesignSystem.Color.textTertiary)
                        .accessibilityHidden(true)
                }
            }

            Text(pack.name)
                .font(DesignSystem.Font.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Color.textPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            progress
        }
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .topLeading)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Color.cardBackground, in: .rect(cornerRadius: DesignSystem.CornerRadius.card))
        .contentShape(.rect(cornerRadius: DesignSystem.CornerRadius.card))
        .opacity(isUnlocked ? 1 : 0.6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pack.name)
        .accessibilityValue(accessibilityValue)
    }
}

// MARK: - Subviews
private extension QuizPackCard {
    var progress: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            ShareBar(
                fraction: pack.levelCount > 0 ? Double(completedLevels) / Double(pack.levelCount) : 0,
                color: pack.color
            )
            HStack(spacing: DesignSystem.Spacing.sm) {
                Label {
                    Text(verbatim: "\(completedLevels)/\(pack.levelCount)")
                } icon: {
                    Image(systemName: "square.grid.3x3.fill")
                }
                Label {
                    Text(verbatim: "\(stars)/\(maxStars)")
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(DesignSystem.Color.warning)
                }
            }
            .font(DesignSystem.Font.caption)
            .monospacedDigit()
            .foregroundStyle(DesignSystem.Color.textSecondary)
            .labelStyle(.titleAndIcon)
        }
    }

    var accessibilityValue: Text {
        isUnlocked
            ? Text("\(completedLevels) of \(pack.levelCount) levels, \(stars) of \(maxStars) stars")
            : Text("Locked")
    }
}
